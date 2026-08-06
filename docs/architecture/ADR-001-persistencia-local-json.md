# ADR 001 — Persistência local JSON

- Status: aceito
- Data: 2026-08-06

## Contexto

Produtos, clientes, campanhas, listas, pedidos, rascunhos e perfil operacional precisam funcionar offline e continuar legíveis para usuários que atualizaram versões publicadas do app.

## Decisão

Usar `JSONFileStore<Value>` por agregado, com envelope versionado, escrita em arquivo temporário seguida de substituição, e um backup rotativo. O leitor aceita o envelope atual e o JSON legado sem envelope. Stores só publicam novo estado em memória depois que a gravação obrigatória termina com sucesso.

## Consequências

- Não existe sincronização entre dispositivos.
- O backup protege a versão imediatamente anterior, não um histórico completo.
- Operações que envolvem dois arquivos, como lista + catálogo, não possuem transação ACID. O identificador estável torna a repetição idempotente; a UI deve permitir tentar novamente.
- Migrações futuras devem preservar leitura anterior ou fornecer migração explícita e testada.
