# Relatório de entrega — fluxo comercial Pedido Fácil

Data: 2026-08-05
Branch: `codex/pedido-facil-sales-flow-80-20`
Base: `7e5d9f2` (`main`)
Estado: P0 e P1 implementados; validação de runtime final pendente por falha do CoreSimulator

## B0 — Estado inicial

Aplicativo SwiftUI já publicado na App Store, com persistência JSON de produtos e pedidos simples. O repositório não possuía testes, lista diária, estados comerciais, clientes estruturados, campanhas, desconto rastreável ou controle configurável do prazo. Treze arquivos já estavam modificados no worktree e foram preservados.

## B1 — Auditoria

A auditoria forense, evidências por símbolo, fluxo anterior e limites de migração estão em `docs/audits/pedido-facil-sales-flow-audit.md`.

## B2 — Problemas encontrados

Os riscos principais eram perda do rascunho, IDs instáveis após decodificação, escrita JSON não atômica, falhas silenciosas, dinheiro sem representação decimal no novo domínio, ausência de revisão de listas, ausência de status e desconto, além de uma tela inicial sem prioridades operacionais. O produto publicado tornou compatibilidade retroativa e recuperação de dados requisitos de P0.

## B3 — Matriz impacto × esforço × risco

A matriz completa está na auditoria. Os maiores retornos foram: persistência/IDs/rascunho, importação revisável, pedido rápido, desconto explícito, Central do Dia e testes. Clientes/campanhas/histórico formaram o P1.

## B4 — Plano 80/20

1. Proteger dados publicados e criar testes.
2. Colar, interpretar, revisar e salvar a lista.
3. Criar pedido com preço de lista e negociado.
4. Resolver desconto sem confundir mensagem enviada com aprovação.
5. Priorizar o trabalho pelo prazo configurável.
6. Acrescentar clientes, ofertas, contatos, recorrência e histórico sem criar um CRM amplo.

## B5 — Arquitetura adotada

A evolução foi incremental, sem reorganização cosmética:

- `Domain/Models`: lista, cliente, campanha, interação, pedido e desconto;
- `Domain/UseCases`: parser determinístico e mensagem de ajuste;
- `Data/Persistence`: envelope JSON versionado, escrita atômica e backup;
- `Features`: stores/view models `@Observable` e views SwiftUI por fluxo;
- views declarativas e regras de cálculo/transição fora das views;
- `Logger` por categoria, sem texto integral de listas ou dados pessoais.

Não foi introduzida dependência externa, backend, IA, OCR, UIKit ou migração destrutiva para SwiftData.

## B6 — Funcionalidades implementadas

- Central do Dia com prazo relativo, default 16:30 configurável, lista ativa e pendências reais;
- configuração de nome da operação, horário e assinatura;
- colagem, parser determinístico, revisão em linha, erros por item e texto-fonte preservado;
- detecção de marca/preço ausentes e duplicidade;
- pedido rápido persistente, cliente estruturado ou nome livre, preço original/negociado e totais em `Decimal`;
- rascunho automático e recuperação após reinicialização;
- desconto com justificativa, mensagem, envio e resolução explícitos;
- estados e histórico de pedido;
- clientes com segmentos/etiquetas editáveis, busca, cidade e arquivamento não destrutivo;
- campanhas com produtos revisados congelados, lista curta/completa e `ShareLink`;
- registro histórico de contato: não contatado, enviado, visualizado, interessado, sem retorno e pedido realizado;
- compras anteriores por cliente e duplicação como novo rascunho com novos IDs;
- histórico filtrável por hoje, ontem, semana, cliente, status e desconto;
- fluxo publicado anterior preservado como “Pedido simples”.

## B7 — Arquivos alterados

Foram adicionados ou alterados 44 arquivos entre a base e esta entrega, concentrados em `Domain`, `Data/Persistence`, `Features`, `PedidoFacilTests`, projeto Xcode e documentação. O diff da branch contém aproximadamente 4.755 adições e 38 remoções. Os treze arquivos inicialmente sujos continuam preservados no worktree; apenas hunks necessários de integração foram commitados.

## B8 — Persistência e migrações

- `products.json` e `clientOrders.json` aceitam o formato legado e o envelope novo;
- IDs legados ausentes são gerados e persistidos sem invalidar leitura anterior;
- escrita usa opção atômica;
- o último arquivo primário válido é preservado como backup;
- arquivo principal inválido pode ser recuperado do backup;
- novas coleções usam arquivos separados: perfil, rascunho, listas, pedidos comerciais, clientes e campanhas;
- pedidos, clientes e campanhas são arquivados/cancelados por estado, não apagados silenciosamente.

Ainda é obrigatório validar uma atualização sobre uma cópia real dos dados da versão da App Store antes de publicar.

## B9 — Testes executados

Comando da última suíte integral concluída antes do incremento P1:

```sh
xcodebuild test -project PedidoFacil.xcodeproj -scheme PedidoFacil \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' \
  -derivedDataPath /tmp/PedidoFacilTestsDerivedData CODE_SIGNING_ALLOWED=NO
```

Resultado: 26 testes aprovados, zero falhas, zero ignorados, aproximadamente 52 s.

Após P1, existem 33 testes. O comando `build-for-testing` concluiu com `TEST BUILD SUCCEEDED`, incluindo os novos testes de clientes, campanhas, mensagens, interações e duplicação. A execução final não iniciou porque os simuladores passaram a travar na migração `00LaunchServicesMigrator`, antes do runner XCTest. Tentativas em dois simuladores existentes e um temporário tiveram o mesmo comportamento; o temporário foi removido. Nenhuma asserção falhou, mas os sete testes novos não podem ser declarados executados.

## B10 — Builds executados

```sh
xcodebuild build -project PedidoFacil.xcodeproj -scheme PedidoFacil \
  -destination 'platform=iOS Simulator,name=iPhone 17e,OS=26.5' \
  -derivedDataPath /tmp/PedidoFacilBuild-iPhone CODE_SIGNING_ALLOWED=NO
```

Resultado: `BUILD SUCCEEDED`, aproximadamente 7 s.

```sh
xcodebuild build -project PedidoFacil.xcodeproj -scheme PedidoFacil \
  -destination 'platform=iOS Simulator,name=iPad Air 11-inch (M4),OS=26.5' \
  -derivedDataPath /tmp/PedidoFacilBuild-iPad CODE_SIGNING_ALLOWED=NO
```

Resultado: `BUILD SUCCEEDED`, aproximadamente 3 s.

Build genérico adicional para iOS Simulator: `BUILD SUCCEEDED`.

## B11 — Evidências e resultados

- 33 testes compilados no target `PedidoFacilTests`;
- build iPhone e iPad concluído;
- `git diff --check` não acusa erros nos arquivos commitados;
- preços de campanha vêm de snapshots da lista revisada;
- mensagens usam o prazo do perfil operacional;
- transições de desconto exigem resolução antes de `readyToSubmit`;
- duplicação cria novo pedido e novos IDs de item;
- logs registram contagens/status, não nomes, telefones ou documentos completos.

Warnings anteriores permanecem em views legadas: `previewLayout` ignorado e interpolação de opcionais. Eles não foram mascarados nem tratados como regressões desta frente.

## B12 — Riscos remanescentes

1. Reexecutar os 33 testes após o CoreSimulator concluir a migração interna.
2. Executar smoke visual e acessibilidade em iPhone/iPad reais ou Simulator saudável.
3. Validar atualização com fixture copiada da versão publicada na App Store.
4. O pedido rápido recebe um snapshot dos clientes ao abrir a Central; clientes cadastrados durante a mesma sessão aparecem após recriar a Central.
5. Arquivados são preservados, mas ainda não há tela de restauração.
6. Não há sincronização entre dispositivos; os dados continuam locais.

## B13 — Itens adiados

- fotos/vídeos e importação avançada de arquivos;
- notificações locais;
- OCR/IA, integração direta com WhatsApp, cloud e backend;
- editor gráfico e relatórios extensos;
- push, merge, release e publicação;
- remoção de compatibilidade legada.

## B14 — Commits criados

```text
4888597 docs: audit sales workflow architecture
af53458 test: preserve persisted order identities
18fed28 feat: add versioned atomic JSON persistence
8f6b88a docs: generalize sales workflow configuration
8045445 feat: add configurable sales deadline profile
eab3458 feat: persist and recover order drafts
d662060 feat: parse and validate daily price lists
191435f feat: add price list review workflow
74c40a9 feat: expose daily price list import
ed58acb feat: add sales order and discount workflow
060bf66 feat: add persistent fast order workflow
84531ef feat: add daily sales control center
d611f0c feat: add persistent customer segments
34fec2d feat: add customer directory and filters
5f442df feat: add campaigns and customer interactions
4514b9b feat: add offer sharing and contact tracking
c3ac388 feat: add recurring customers and order duplication
2d469aa feat: surface daily sales priorities
0efd1d2 feat: add actionable sales history
6f60141 test: add isolated previews and accessibility hooks
```

## B15 — Estado da branch e worktree

A branch de trabalho continua separada de `main`. Não houve merge, push, tag, release ou deploy. O worktree permanece modificado pelos treze arquivos preexistentes; eles não devem ser descartados ou incluídos automaticamente numa futura publicação.

## B16 — Próximo incremento recomendado

Primeiro, recuperar o runtime do Simulator e executar os 33 testes, smoke dos fluxos lista → oferta → cliente → pedido → desconto → conclusão e uma atualização sobre fixture real da App Store. Somente depois avaliar notificações contextuais e anexos de mídia. Nenhuma publicação deve ocorrer antes desses gates.
