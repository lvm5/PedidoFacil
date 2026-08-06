# Contrato de persistência

## Arquivos

| Agregado | Arquivo | Dono |
|---|---|---|
| Produtos | `products.json` | `ProductModel` |
| Clientes | `customers.json` | `CustomerStore` |
| Campanhas | `campaigns.json` | `CampaignStore` |
| Listas diárias | `dailyPriceLists.json` | `PriceListImportViewModel` |
| Pedidos comerciais | `salesOrders.json` | `FastOrderViewModel` |
| Rascunho comercial | `currentSalesOrderDraft.json` | `FastOrderViewModel` |
| Pedidos simples | `clientOrders.json` | `OrderViewModel` |
| Rascunho simples | `currentOrderDraft.json` | `OrderViewModel` |
| Perfil operacional | `operationalProfile.json` | `OperationalSettings` |

## Invariantes

1. Gravações usam o envelope versionado do `JSONFileStore`.
2. Um JSON legado válido continua legível e vira envelope na próxima alteração.
3. Estado observável não confirma uma inclusão, edição, exclusão ou arquivamento que falhou no disco.
4. Falhas são registradas e, nas superfícies editáveis, apresentadas ao usuário sem descartar o trabalho.
5. Horários válidos são `00:00...23:59`; JSON fora desse intervalo é rejeitado.
6. A publicação de lista usa o mesmo UUID em repetições, evitando duplicatas após falha parcial.

## Importação e catálogo

Salvar uma lista revisada não basta para vender: a publicação deve gravar os produtos em `products.json` e marcar a lista como publicada. O preço da tabela é `sellingPrice`. Sem custo informado, `purchasePrice = sellingPrice` e `purchasePriceIsProvisional = true`.

## Recuperação

Na corrupção do primário, o store tenta o backup. Falha de primário e backup não autoriza substituir silenciosamente dados por uma coleção vazia. Operações entre arquivos são compensáveis/idempotentes, mas não atômicas.
