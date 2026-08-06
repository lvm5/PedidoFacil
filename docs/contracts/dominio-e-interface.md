# Contrato de domínio e interface

## Produtos e preços

- Nome não pode ser vazio; venda deve ser maior que zero; custo não pode ser negativo; unidades por embalagem devem ser positivas.
- Custo provisório permanece visível até confirmação explícita na edição.
- Tocar uma linha de produto abre a edição; excluir exige confirmação.

## Clientes, endereços e rotas

- Endereço é opcional e estruturado em logradouro, número, complemento, bairro, cidade, UF e CEP.
- Dias de entrega são configuráveis por cliente/rota; sugestões de cidades são conveniências editáveis, não regras globais.
- Clientes arquivados não entram na seleção operacional padrão.

## Perfil operacional

- Início, limite de envio, lembretes, segmentos e assinatura pertencem ao perfil configurável.
- `16:30` é apenas o valor inicial sugerido.

## Listas

- PDF e texto produzem itens em revisão; nenhuma linha incompleta deve parecer confirmada.
- Atacado e varejo permanecem listas independentes.
- Publicar disponibiliza produtos para catálogo e pedido rápido; repetir após erro não duplica a lista.

## Pedidos

- Rascunhos não são perdidos quando salvar o pedido falha.
- Pedido recusado pode ser cancelado e copiado para um novo rascunho revisável.
- Exclusão em listas ordenadas resolve o UUID visível, nunca o índice da coleção original.
- Mensagens externas mostram valores de venda; margem/custo não deve ser exposto ao cliente sem intenção explícita.

## UI/UX

- A navegação raiz tem no máximo cinco tarefas frequentes.
- Controles usam componentes e símbolos do sistema, rótulos inequívocos e estados vazio/erro.
- Ações destrutivas pedem confirmação; ações que falham preservam entradas.
- Cor não é o único indicador; conteúdo suporta Dynamic Type, VoiceOver e modo claro/escuro.
