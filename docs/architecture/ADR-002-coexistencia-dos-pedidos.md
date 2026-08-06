# ADR 002 — Coexistência dos domínios de pedido

- Status: aceito, transitório
- Data: 2026-08-06

## Contexto

Versões antigas persistem `ClientOrder`/`OrderItem`. O fluxo comercial atual usa `SalesOrder`, com cliente referenciado, status, histórico, desconto e rota.

## Decisão

`SalesOrder` é a fonte do histórico principal e ocupa a aba Pedidos. O fluxo antigo permanece acessível em Início > Pedido simples e continua lendo `clientOrders.json`. Não unificar ou excluir automaticamente arquivos durante esta versão.

## Consequências

- Dados antigos continuam utilizáveis.
- Resumos financeiros e sugestões do fluxo legado não representam pedidos comerciais novos; por isso não são destinos raiz.
- A remoção futura exige migração com reconciliação de produtos/clientes e aceite explícito.
