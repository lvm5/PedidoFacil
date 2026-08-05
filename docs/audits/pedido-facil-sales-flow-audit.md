# Auditoria E2E — fluxo comercial Pedido Fácil

Data da linha de base: 2026-08-05
Branch de trabalho: `codex/pedido-facil-sales-flow-80-20`
Commit-base local: `7e5d9f2cc0d1921df3586f6074bfa78ff5cf193f` (`Adjust views`)
Branch-base: `main`, um commit à frente de `origin/main` (`501b37e`) no início da auditoria

## 1. Estado atual

Na linha de base, o repositório continha um único target de aplicação, `PedidoFacil`, sem dependências externas e sem targets de testes. O projeto foi criado com Xcode 16.2, está configurado com Swift 5, deployment target iOS 18.2 e famílias iPhone/iPad. A linha de base foi verificada com Xcode 26.6 (build 17F113), SDK iOS Simulator 26.5. O incremento `af53458` adicionou o primeiro target unitário.

O produto atual é um MVP SwiftUI para cadastro de produtos, composição de um pedido por cliente, histórico simples, cálculo de venda/lucro, sugestão de compra e compartilhamento textual. A persistência usa JSON no diretório Documents. Segundo confirmação do proprietário em 2026-08-05, o aplicativo já está publicado na App Store e disponível para download; portanto, o formato persistido e o comportamento de atualização devem ser tratados como produção instalada, não como protótipo descartável.

O produto publicado deve continuar útil para outros vendedores e operações comerciais. As necessidades do proprietário formam o caso principal e os defaults iniciais, mas não autorizam hardcode de empresa, canal, segmentos ou horário. O design deve oferecer configuração mínima e progressive disclosure, preservando a simplicidade para quem usa os padrões.

Não há arquitetura MVVM-C completa. Há models de valor (`Product`, `OrderItem`, `ClientOrder`), dois objetos globais `ObservableObject` (`ProductModel` e `OrderViewModel`), um gerador de mensagem e views SwiftUI. Não há coordinator, repository, use case, protocolo de persistência ou injeção de dependências por feature.

### Proteção do repositório

- O worktree inicial em `main` já continha 13 arquivos modificados, 77 adições e 30 remoções.
- As alterações prévias ajustam disponibilidade de iOS 26 para iOS 18, compatibilidade de `listSectionMargins`, parsing de decimal, validações contra divisão por zero e atualização de listas derivadas.
- Essas alterações foram preservadas sem stash, descarte ou reescrita.
- A referência local inválida `.git/refs/remotes/origin/HEAD 2` bloqueava `git fetch`; somente esse ponteiro remoto duplicado e reconstruível foi removido. O fetch seguinte restaurou `origin/main` e confirmou o remoto.
- Nenhum merge, release, deploy ou push foi executado.

Arquivos previamente modificados:

- `PedidoFacil/PedidoFacilApp.swift`
- `PedidoFacil/View/Components/Background/BackgroundView.swift`
- `PedidoFacil/View/Components/ButtonsBox/ActionButtonsView.swift`
- `PedidoFacil/View/Components/ButtonsBox/OrderClientFormView.swift`
- `PedidoFacil/View/Components/MainTabView.swift`
- `PedidoFacil/View/HomeView.swift`
- `PedidoFacil/View/Orders/OrderDetailView.swift`
- `PedidoFacil/View/OrdersView.swift`
- `PedidoFacil/View/Products/ProductEditView.swift`
- `PedidoFacil/View/Products/ProductRowView.swift`
- `PedidoFacil/View/ProductsView.swift`
- `PedidoFacil/View/Profits/ProfitView.swift`
- `PedidoFacil/ViewModel/OrderViewModel.swift`

## 2. Fluxo atual do aplicativo

```text
Inicialização
→ carrega products.json e clientOrders.json
→ se produtos estiverem vazios, grava catálogo de exemplo
→ TabView: Início | Pedidos | Produtos | Lucros

Início
→ digita nome do cliente
→ escolhe produto em Menu
→ digita quantidade
→ calcula preço/lucro
→ adiciona item
→ finaliza e persiste pedido

Pedidos
→ lista histórico salvo
→ abre detalhe
→ compartilha recibo textual

Produtos
→ busca, cadastra, edita ou exclui produto

Lucros
→ mostra totais acumulados de venda e lucro
```

Evidências: `PedidoFacilApp.body`, `MainTabView.body`, `HomeView.body`, `OrderViewModel.saveClientOrder()`, `ProductsView.body`, `OrdersView.body`, `OrderDetailView.receiptText` e `FinancialSummaryView.body`.

## 3. Problemas reais encontrados

### P0 — integridade e continuidade operacional

1. **Rascunho não é persistido.** `OrderViewModel.orders`, `clientName`, `quantityKg` e o produto selecionado vivem apenas em memória; somente `clientOrders` é gravado. Encerrar o app durante a montagem perde o trabalho corrente. Evidência: `OrderViewModel` e sua extensão privada de persistência.
2. **Identidades de pedidos e itens mudam após reiniciar.** `ClientOrder.id` e `OrderItem.id` são `let id = UUID()`. O compilador alerta que essas propriedades não são decodificadas; ao carregar JSON, novos UUIDs são gerados. Isso impede histórico estável e futuras relações. Evidência: `ClientOrder.swift:11`, `OrderItem.swift:12` e warnings do build.
3. **Persistência de produção não é atômica nem versionada.** `Data.write(to:)` é usado sem `.atomic`, schema/versionamento, backup ou estratégia de recuperação. Uma escrita interrompida pode inutilizar o arquivo; qualquer evolução estrutural depende do comportamento permissivo de `Codable`. Como o app já é distribuído pela App Store, esse risco alcança instalações e dados existentes. Evidência: `ProductModel.saveProductsToDisk()` e `OrderViewModel.saveClientOrdersToDisk()`.
4. **Falhas são silenciosas para o vendedor.** Validações e erros de disco usam somente `print`; as views não recebem estado de erro nem ação de recuperação. Evidência: `OrderViewModel.calculate()`, `saveClientOrder()`, `ProductModel` e extensão de persistência do `OrderViewModel`.
5. **Produto placeholder pode virar item real.** `selectedProduct` começa como um `Product` sintético e `addOrder()` valida apenas a quantidade. Um pedido pode conter “Selecione um produto” com preço zero. Evidência: `OrderViewModel.selectedProduct` e `addOrder()`.
6. **Dinheiro usa `Double`.** Compra, venda, subtotal e lucro usam ponto flutuante binário, inadequado para valores comerciais exatos e descontos. Evidência: `Product.purchasePrice`, `sellingPrice`, `OrderItem.totalPrice` e cálculos do `OrderViewModel`.

### P0 — lacunas do novo fluxo

7. Não existem lista diária, texto-fonte, revisão por item, parser, validade, mídia, campanha, cliente persistente, interação, desconto, status, histórico de status ou sessão diária.
8. A tela inicial é exclusivamente um formulário de pedido; não mostra prazo operacional, pendências ou ações do dia. Para o caso principal, o default sugerido é 16h30, mas o horário precisa ser configurável. Evidência: `HomeView.body` e confirmação do proprietário em 2026-08-05.
9. O pedido não separa preço original, negociado e desconto. `OrderItem.totalPrice` sempre usa `product.sellingPrice`.
10. Não há salvamento automático, recuperação, duplicação, recentes ou compras anteriores por cliente.
11. `OrderMessageGenerator.generateMessage` inclui lucro interno na mensagem e usa interpolação de opcionais, podendo produzir `Optional(...)`; esse método não está ligado à UI atual, mas é inseguro para comunicação externa. O recibo não inclui status nem rastreabilidade.

### P1 — arquitetura e manutenção

12. `OrderViewModel` concentra estado de formulário, pedidos, histórico, sugestão de compra, cálculos, geração textual e I/O. Isso mistura apresentação, domínio e dados e dificulta testes.
13. `ProductModel` está em `Model/`, mas é simultaneamente store, repository, seed loader e persistence service.
14. Navegação é distribuída entre `TabView`, três `NavigationView`, um `NavigationStack` e sheets locais; não há coordinator nem rotas tipadas.
15. `CompatListSectionMargins` é duplicado em três arquivos (`OrdersView`, `OrderDetailView`, `ProductsView`).
16. `CalculationResultViewChild` duplica a apresentação já embutida em `ActionButtonsView` e não possui referência de uso.
17. `OrderClientFormView`, `PriceInfoView` e `PurchaseSuggestionsView` não aparecem no fluxo principal atual ou têm uso parcial, indicando código desconectado.
18. `HeaderView` recebe `onClearAll` e `isClearDisabled`, mas não usa nenhum dos dois parâmetros.
19. `FinancialSummaryView.orders` não é usado; os valores vêm do environment object.
20. Há imports redundantes (`Foundation`, `Swift`) e comentários extensos/obsoletos, mas isso é dívida menor e não justifica reorganização ampla.

### P1 — UX, acessibilidade e adaptação

21. Várias previews falham por dependências de ambiente ausentes: `HomeView` não injeta `OrderViewModel`; `FinancialSummaryView` não injeta environment object; outras previews inicializam stores que leem/gravam dados reais em Documents.
22. Não há fixtures isoladas nem estados loading/empty/error/success definidos por feature.
23. Não há uso explícito de APIs de acessibilidade, identificadores para UI tests ou validação de Dynamic Type.
24. A tela de seleção usa um `Menu` longo, sem busca contextual; isso não escala para pedido rápido.
25. A ação “Editar” de `ProductRowView` persiste os mesmos preços locais e altera `selectedProduct`, enquanto tocar na linha abre o editor. O rótulo e o comportamento não correspondem.
26. O layout usa muitos materiais, gradiente e blocos visuais sem hierarquia operacional. A Central do Dia deve substituir decoração por prioridade e ação.
27. `NavigationView` está obsoleto para o deployment target atual; a migração para `NavigationStack`/`NavigationSplitView` pode ser incremental.
28. A entrada decimal substitui vírgula por ponto, mas não usa uma estratégia locale-aware completa e não expõe erro em linha.

### P1 — logs, privacidade e segurança

29. Não existe `Logger`; `print` registra mensagens sem categoria ou nível. Algumas mensagens futuras poderiam expor dados se o padrão continuar.
30. Os JSONs ficam legíveis no diretório Documents. Não há classificação dos dados, proteção adicional, política de retenção ou exportação controlada.
31. A exclusão de produtos e pedidos é imediata e sem histórico. Para o novo domínio, pedidos e mudanças comerciais não devem ser apagados silenciosamente.
32. O README anuncia licença não comercial apesar do objetivo comercial do app. Isso é uma decisão jurídica/produto a revisar, não uma alteração automática de código.

### P2 — qualidade e performance

33. Não há target de testes; portanto, nenhum teste unitário, integração ou UI é executável atualmente.
34. Agregações de pedidos e listas são recalculadas em memória com dicionários e loops. Isso é aceitável no volume atual, mas o uso de `Product` inteiro como chave inclui campos mutáveis como preço e `calculatedUnits`, podendo fragmentar o agrupamento do mesmo produto após edições.
35. `NumberFormatter` é criado a cada chamada de `Double.asCurrency`; impacto pequeno hoje, mas evitável em listas grandes.
36. Builds iPhone e iPad passam, porém apresentam warnings de previews ignoradas, interpolação de opcionais e IDs não decodificados.

## 4. Lacunas em relação ao fluxo alvo

| Etapa alvo | Estado atual | Lacuna mínima |
|---|---|---|
| Entrada diária | inexistente | captura do texto original e data/validade |
| Revisar produtos | editor individual | parser determinístico + revisão em lote e erros por linha |
| Publicar oferta | recibo/lista de compra | gerador de oferta curta/completa a partir da lista revisada |
| Selecionar clientes | nome livre no pedido | cliente persistente, segmento e filtros simples |
| Registrar retorno | inexistente | interação e status por campanha/cliente |
| Criar pedido | MVP funcional | cliente estruturado, busca, preço original/negociado e rascunho |
| Tratar desconto | inexistente | cálculo, justificativa, mensagem e estado explícito |
| Lançar no app da empresa | inexistente | checklist/status manual; sem integração direta nesta frente |
| Concluir | salvar pedido simples | máquina de estados e histórico imutável |
| Prazo operacional | inexistente | horário configurável, default 16h30, e priorização relativa de pendências |

## 5. Matriz impacto × esforço × risco

Escala: 1 (baixo) a 5 (alto). Prioridade combina valor operacional e redução de risco, não uma soma automática.

| Incremento | Impacto | Esforço | Risco | Prioridade | Evidência/razão |
|---|---:|---:|---:|---|---|
| Persistência versionada, IDs estáveis e rascunho | 5 | 3 | 4 | P0 | evita perda e cria base para histórico |
| Lista diária + parser + revisão | 5 | 4 | 3 | P0 | elimina digitação repetitiva sem IA externa |
| Pedido rápido com preço original/negociado | 5 | 4 | 4 | P0 | núcleo da operação e pré-requisito do desconto |
| Fluxo de desconto e mensagem | 5 | 3 | 3 | P0 | resolve bloqueio externo rastreável |
| Central do Dia e prazo configurável | 5 | 3 | 2 | P0 | orienta ação antes do horário de cada operação |
| Test target + unitários críticos | 5 | 3 | 2 | P0 | reduz regressões em cálculo e migração |
| Clientes e segmentos | 4 | 3 | 3 | P1 | permite oferta e histórico por público |
| Campanhas e interações | 4 | 4 | 3 | P1 | fecha rastreabilidade de abordagem/retorno |
| Histórico e duplicação | 4 | 3 | 3 | P1 | acelera recorrência e auditoria |
| Mídia e importação de arquivos | 2 | 4 | 3 | P2 | útil, mas texto resolve o maior volume primeiro |
| Notificações locais | 2 | 2 | 2 | P2 | benefício secundário; exige permissão contextual |
| IA/OCR/cloud/WhatsApp direto | incerto | 5 | 5 | P3 | depende de valor, privacidade, custo e autorização |

## 6. Plano 80/20

### Incremento 0 — fundação segura

- Criar target de testes.
- Introduzir IDs persistíveis e tipos de dinheiro/quantidade com compatibilidade de leitura do JSON existente.
- Extrair um repository JSON atômico, versionado e injetável.
- Persistir e recuperar rascunho.
- Substituir `print` por `Logger` categorizado e estados de erro apresentáveis.

### Incremento 1 — entrada diária completa

- `DailyPriceList` e `PriceListItem` com texto original, timestamps e validade.
- Parser determinístico para padrões brasileiros comuns, preservando exatamente marca e preço detectados.
- Revisão em lote com flags de marca, preço, duplicidade e ambiguidade.
- Salvar somente após confirmação explícita.

### Incremento 2 — pedido rápido e desconto

- Cliente → busca/recorrentes → quantidade → revisão.
- Separar preço de lista e negociado; calcular desconto em `Decimal`.
- Máquina de estados do pedido com transições testadas.
- Mensagem de ajuste e marcações enviado/ajustado/recusado/substituído.

### Incremento 3 — Central do Dia

- Uma lista operacional, não um dashboard de cards.
- Prazo configurável (`submissionDeadline`), com 16h30 como default sugerido, lista ativa e grupos acionáveis: contatar, resolver desconto, lançar e concluir.
- Lembretes relativos ao prazo (por exemplo, −60, −30 e −10 minutos), evitando horários absolutos duplicados no código.
- Ações principais: importar lista, criar pedido, enviar ofertas e resolver pendências.

### Incremento 4 — clientes, campanhas e histórico

- Cliente persistente com segmento e etiquetas simples.
- Segmentos iniciais sugeridos, mas editáveis, para servir outros ramos sem introduzir um CRM complexo.
- Campanha textual curta/completa e `ShareLink`.
- Interações e histórico de status.
- Duplicar pedido e sugerir recorrentes sem decisão automática.

## 7. Arquivos afetados previstos

Manter os arquivos existentes e adicionar estrutura progressivamente, sem movimentação cosmética:

```text
PedidoFacil/
  Domain/Models/
  Domain/Repositories/
  Domain/UseCases/
  Data/Persistence/
  Data/Repositories/
  Features/DailySales/
  Features/PriceLists/
  Features/Customers/
  Features/Campaigns/
  Features/Orders/
  Features/Discounts/
  Navigation/
  Shared/Logging/
PedidoFacilTests/
PedidoFacilUITests/ (quando o fluxo estiver estável)
```

`PedidoFacilApp.swift`, `MainTabView.swift`, models e stores atuais serão adaptados por incremento. Os 13 arquivos previamente modificados exigem revisão de sobreposição antes de cada edição.

## 8. Estratégia de persistência e migração

1. Não substituir os JSONs existentes de uma vez; considerar os arquivos atuais um contrato de produção já distribuído.
2. Criar envelopes versionados e decoders legados para `products.json` e `clientOrders.json`.
3. Fazer backup antes da primeira conversão, escrever de forma atômica e manter leitura compatível com pelo menos o formato publicado atual.
4. Preservar IDs existentes quando disponíveis; para dados legados sem ID decodificável, gerar uma vez durante a migração e persistir imediatamente.
5. Modelar novas entidades separadamente, evitando que uma falha numa lista diária corrompa pedidos.
6. Tornar repositories injetáveis para testes e previews; usar diretório temporário nesses ambientes.
7. Só considerar SwiftData se uma prova de migração demonstrar ganho líquido em fixture copiada de uma instalação publicada. O JSON existente é a menor rota segura inicial.
8. Nunca apagar automaticamente pedidos, descontos ou histórico; usar status/arquivamento.
9. Antes de qualquer release, validar atualização sobre uma instalação com dados no formato da versão da App Store, além de instalação limpa; exportar/recuperar backup e testar downgrade somente quando tecnicamente suportado.
10. Separar compatibilidade de leitura, migração persistida e remoção de código legado em releases diferentes. Não remover decoder legado na mesma versão que introduz o novo envelope.

## 9. Estratégia de testes

### Unitários primeiro

- Codable/migração e estabilidade de IDs.
- Escrita atômica, recuperação de arquivo inválido e rascunho.
- Parser com vírgula decimal, marcas ausentes, preços ausentes, duplicidades e linhas ignoradas.
- Dinheiro, subtotal, desconto percentual e impacto total.
- Transições válidas/inválidas de status.
- Prazo antes, próximo e depois de um `submissionDeadline` configurável com relógio, calendário e fuso local injetáveis.
- Geradores de oferta, pedido e ajuste sem exposição de lucro ou opcionais.

### Integração

- colar → revisar → salvar → reler;
- pedido → rascunho → reiniciar store → recuperar;
- pedido negociado → desconto → mensagem → mudança de status;
- campanha → clientes → interações.
- fixture de produção legada → atualizar app → migrar → reiniciar → preservar produtos e pedidos;
- arquivo principal corrompido → restaurar backup sem sobrescrever a última cópia válida.

### UI e acessibilidade

- criar pedido, corrigir item inválido e resolver desconto;
- estados vazio/erro/prazo próximo;
- labels, ordem de foco, tamanhos de toque e Dynamic Type;
- portrait/landscape em iPhone e iPad e teclado no iPad.

### Linha de base executada

- iPhone 17 Pro, iOS Simulator 26.5: `BUILD SUCCEEDED`.
- iPad Air 11-inch (M4), iOS Simulator 26.5: `BUILD SUCCEEDED`.
- Runtime não executado: nenhum Simulator estava iniciado e não foi iniciado sem solicitação explícita.
- Testes não executados: o projeto não possui target de testes.

## 10. Métricas operacionais

As métricas servem decisões diárias e devem ser instrumentadas localmente, sem dados pessoais nos logs.

### KPIs primários

1. **Tempo de lista pronta**: de `importStartedAt` até confirmação da revisão. Meta inicial provisória: mediana ≤ 3 min; validar com 10 dias reais antes de fixar SLA.
2. **Tempo de pedido pronto**: da seleção do cliente até `readyToSubmit`. Meta inicial provisória: mediana ≤ 90 s para pedido recorrente e ≤ 3 min para pedido novo.
3. **Conclusão no prazo**: pedidos confirmados concluídos até o `submissionDeadline` configurado ÷ pedidos confirmados do dia. O default sugerido é 16h30; a meta operacional inicial é 100%, com contagem absoluta sempre visível para evitar esconder baixo volume.

### Drivers

- campos obrigatórios preenchidos manualmente por lista/pedido;
- toques da entrada válida até salvar e do cliente até finalizar;
- itens que exigem correção na revisão;
- pedidos confirmados ainda não lançados às 16h00 e 16h20;
- descontos aguardando ajuste e idade da pendência;
- clientes abordados sem retorno.

### Guardrails

- zero alteração silenciosa de marca ou preço;
- zero rascunho perdido em reinicialização controlada;
- zero desconto considerado aprovado somente por gerar/enviar mensagem;
- taxa de falha de persistência visível e acionável, nunca apenas logada.

Não há baseline de uso real no repositório. As metas de tempo são hipóteses de produto e devem ser recalibradas com eventos locais revisados e confirmação do vendedor.

### Configuração mínima para um produto geral

- nome da operação/vendedor para cabeçalhos opcionais;
- horário limite diário, com 16h30 sugerido na primeira configuração;
- moeda e locale derivados do dispositivo, com confirmação quando necessário;
- segmentos e etiquetas iniciais editáveis;
- assinatura das mensagens e texto de encerramento;
- canal de compartilhamento escolhido pelo share sheet, sem integração exclusiva com uma empresa.

Esses campos devem aparecer num onboarding curto ou em Ajustes, não bloquear o primeiro pedido e não aumentar os campos obrigatórios do fluxo diário.

## 11. Itens explicitamente adiados

- IA externa, OCR avançado, integração direta com WhatsApp, cloud sync, backend, recomendação preditiva e editor gráfico.
- Migração completa para SwiftData sem prova de compatibilidade.
- Relatórios extensos e gráficos sem decisão operacional.
- Reorganização total de pastas, design system amplo ou reescrita arquitetural.
- Notificações locais antes de validar que os lembretes internos são insuficientes.
- Merge, release, deploy e push sem autorização explícita.

## 12. Riscos remanescentes

- O worktree contém mudanças prévias não commitadas misturadas ao futuro trabalho; commits deverão usar staging seletivo e registrar autoria/scope com cuidado.
- O app já está disponível na App Store; uma falha de migração pode causar perda de dados em instalações reais.
- Não há nesta auditoria uma fixture anonimizada extraída de uma instalação publicada para validar migração, volumes, parser ou metas.
- Build verde não comprova previews, runtime, acessibilidade ou persistência após reinício.
- O uso comercial pode conflitar com a licença não comercial documentada no README; requer decisão do proprietário.
- A compatibilidade mínima real é iOS 18.2, apesar de alguns comentários do README mencionarem versões diferentes.

## 13. Próximo incremento recomendado

Implementar primeiro a fundação segura: capturar fixtures legadas representativas, criar target unitário, IDs estáveis, `Decimal`, repository JSON atômico/versionado, logger e rascunho recuperável. Esse incremento reduz o maior risco operacional e permite desenvolver parser, pedidos e descontos sobre uma base testável sem migração destrutiva. Nenhuma release deve ocorrer antes do teste explícito de atualização da versão publicada com dados preservados.
