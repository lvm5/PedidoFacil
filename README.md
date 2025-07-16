# 📦 PedidoFácil – App de Gestão de Pedidos e Compras

Aplicativo iOS desenvolvido com SwiftUI para **gestão simples de pedidos, cálculo de lucro e geração de lista de compras**, com visual moderno e usabilidade prática.  
Ideal para pequenos negócios que vendem produtos por peso e precisam controlar compras por demanda de clientes.

---

## 🧑‍💻 Desenvolvedor
- **Nome:** Leandro Vansan de Morais    
- **Data de criação:** Julho de 2025  

---

## 🎯 Objetivo do Projeto

- Cadastrar produtos com preço de compra e venda, embalagem e peso.
- Registrar pedidos por cliente com cálculo automático do valor e do lucro.
- Gerar automaticamente uma **lista de compras** com base na demanda dos pedidos.
- Criar e exibir um **cupom personalizado** com o resumo do pedido do cliente.
- Copiar esse cupom para envio via WhatsApp, SMS ou qualquer outro meio.

---

## 🛠 Funcionalidades

### ✅ Cadastro de Produtos
- Nome, marca, categoria (aves, carnes, laticínios, etc.)
- Preço de compra, preço de venda
- Tipo de embalagem (unidade, caixa, pacote)
- Peso por embalagem

### ✅ Registro de Pedidos
- Seleção do produto e inserção da quantidade em kg
- Cálculo automático do valor total do item e lucro
- Lista de pedidos exibida com total por item

### ✅ Cupom de Pedido
- Insere nome do cliente
- Gera cupom em texto com:
  - Lista dos produtos
  - Total a pagar
  - Lucro estimado
- Copia automaticamente para área de transferência

### ✅ Lista de Compras
- Soma a quantidade de cada produto de todos os pedidos
- Verifica se fecha uma embalagem completa
- Mostra produtos que precisam ser comprados
- Lista separada de itens em **espera** (quantidade insuficiente para comprar)

---

## 🧑‍🏫 Conceitos e Tecnologias Aplicadas

| Conceito Swift/SwiftUI         | Aplicação prática                                                                 |
|-------------------------------|-------------------------------------------------------------------------------------|
| `@State`, `@Binding`          | Controle de variáveis mutáveis como produtos e pedidos                             |
| `@Environment(\.colorScheme)` | Detecta modo escuro ou claro                                                       |
| `Picker`, `List`, `Menu`      | Criação de interfaces interativas e dinâmicas                                      |
| `Identifiable`, `Hashable`    | Permite uso de structs em ForEach e Picker                                         |
| `guard let`, `Double(...)`    | Conversão segura de String para Double em inputs                                   |
| `Computed Properties`         | `totalPrice`, `totalProfit` calculados automaticamente                            |
| `Clipboard (UIPasteboard)`    | Copia do texto do cupom para envio por qualquer canal                              |
| `Text` com interpolação       | Exibição formatada de mensagens e valores                                          |
| `Codable`                     | Permite salvar ou exportar os dados se quiser expandir o app futuramente          |
| `FileManager` (futuramente)   | Pode ser usado para persistir histórico de pedidos                                 |

---

## 📱 Design

- Interface 100% em **SwiftUI**
- Visual moderno com:
  - `LinearGradient`
  - `glassEffect` (iOS 17+)
  - `VStack`, `ZStack`, `Spacer` para layout responsivo

---

## 🧪 Lógica de negócio aplicada

- Pedido por cliente gera uma `ClientOrder` com `OrderItem`
- Total e lucro são somados automaticamente
- A lógica de lista de compras usa:
  - `Dictionary` para agrupar
  - `reduce` para somar
  - Arredondamento para baixo (comprar apenas embalagens completas)
  - "sobra" vai para lista de espera

---

## 📤 Como funciona o envio do cupom?

1. O usuário registra os pedidos
2. Ao finalizar, insere o nome do cliente
3. O app gera um **cupom em texto**
4. O texto é copiado automaticamente para a **área de transferência**
5. O usuário pode **colar onde quiser**: WhatsApp, Instagram, SMS, E-mail...

---

## 📚 Documentação Oficial Referenciada

- [SwiftUI – Picker](https://developer.apple.com/documentation/swiftui/picker)
- [SwiftUI – List](https://developer.apple.com/documentation/swiftui/list)
- [SwiftUI – State](https://developer.apple.com/documentation/swiftui/state)
- [Swift – Hashable](https://developer.apple.com/documentation/swift/hashable)
- [Swift – Identifiable](https://developer.apple.com/documentation/swift/identifiable)
- [UIPasteboard](https://developer.apple.com/documentation/uikit/uipasteboard)
- [Text Interpolation](https://developer.apple.com/documentation/swiftui/text)

---

## 🚀 Evoluções Futuras

- Exportar pedidos em PDF ou .txt
- Histórico de pedidos por cliente
- Persistência de dados com `FileManager` ou `UserDefaults`
- Compartilhamento direto com `ShareLink`

---

## ✅ Status:  
📦 **Projeto em desenvolvimento — versão MVP funcional pronta!**

---
