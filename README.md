# PedidoFácil

Aplicativo iOS publicado para transformar tabelas de fornecedores e ofertas em produtos revisáveis, pedidos e comunicação comercial. O app atende operações diferentes: horários, segmentos, rotas, dias de entrega e assinatura são configuráveis, sem restringir o produto a uma empresa ou cidade.

## Fluxo principal

1. Importe um PDF ou texto e revise cada item.
2. Salve e publique a lista; os produtos passam a existir no catálogo.
3. Selecione cliente e itens, revise valores e salve o pedido.
4. Acompanhe o pedido, desconto, rota e entrega no histórico.

O preço informado pela tabela é o preço de venda. Quando não existe custo de compra conhecido, o app copia provisoriamente o preço de venda e identifica o custo como pendente de confirmação.

## Áreas do app

- **Início:** central do dia, perfil operacional, campanhas, pedido rápido e acesso ao pedido simples legado.
- **Listas:** importação de PDF/texto, revisão, salvamento e publicação no catálogo.
- **Pedidos:** histórico comercial, estados do pedido, desconto e revisão de pedido recusado.
- **Clientes:** cadastro, endereço, cidade, rota e dias de entrega.
- **Produtos:** catálogo persistido e edição de preços/embalagens.

## Arquitetura

- SwiftUI, iOS 18.2 ou posterior.
- Estado raiz compartilhado em `MainTabView`.
- Persistência local JSON versionada, gravação atômica e um backup rotativo.
- Compatibilidade de leitura com os JSONs legados.
- Dois domínios de pedido coexistem durante a migração: `SalesOrder` é o fluxo principal; `ClientOrder` permanece acessível pelo “Pedido simples”.

Decisões e contratos:

- [ADR 001 — persistência local](docs/architecture/ADR-001-persistencia-local-json.md)
- [ADR 002 — coexistência legado/novo](docs/architecture/ADR-002-coexistencia-dos-pedidos.md)
- [ADR 003 — navegação e estado](docs/architecture/ADR-003-navegacao-e-estado-raiz.md)
- [Contrato de persistência](docs/contracts/persistencia.md)
- [Contrato de domínio e interface](docs/contracts/dominio-e-interface.md)
- [Inventário E2E](docs/audits/e2e-total-2026-08-06.md)

## Desenvolvimento e validação

Abra `PedidoFacil.xcodeproj`, selecione o scheme `PedidoFacil` e um Simulator compatível. O projeto inclui testes XCTest para modelos, stores, parsing, campanhas, rotas, importação e pedidos.

Cada alteração deve ocorrer em branch específica, atualizar `MAJOR.MINOR.PATCH` conforme SemVer e preservar um caminho reversível antes do merge na `main`. Build, testes, análise estática, execução no Simulator, dispositivo físico e disponibilidade na App Store são evidências distintas.

## Privacidade

Os dados operacionais ficam no contêiner local do app. Compartilhamento só ocorre por ação explícita do usuário através das superfícies do sistema.

## Licença

Creative Commons Atribuição-NãoComercial-CompartilhaIgual 4.0 Internacional (CC BY-NC-SA 4.0). Consulte o [texto legal](https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode).

Copyright © 2025–2026 Leandro Vansan de Morais.
