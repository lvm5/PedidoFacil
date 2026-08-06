# ADR 003 — Navegação e estado raiz

- Status: aceito
- Data: 2026-08-06

## Contexto

O app possuía seis abas e instâncias independentes do pedido rápido, permitindo divergência entre Início e Histórico.

## Decisão

Manter cinco destinos de primeiro nível: Início, Listas, Pedidos, Clientes e Produtos. `MainTabView` é dona das instâncias compartilhadas de stores/modelos e propaga referências estáveis por identificador. Telas internas usam `NavigationStack`, `NavigationLink`, sheets e controles nativos.

## Consequências

- Um pedido aberto no histórico usa o mesmo estado do fluxo rápido.
- Lucro e pedido simples deixam de competir por espaço na navegação raiz, mas permanecem preservados no código legado.
- Novas áreas devem entrar como destinos internos, salvo evidência de que são tarefas raiz frequentes.
