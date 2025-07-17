//
//  ContentView.swift
//  PedidoFacil
//
//  Created by Leandro Morais on 2025-07-15.
//

import SwiftUI

@available(iOS 26.0, *)
struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State private var quantityKg: String = ""
    @State private var totalPrice: Double = 0.0
    @State private var totalProfit: Double = 0.0
    @State private var selectedProduct: Product = sampleProducts[0]
    @State private var orders: [OrderItem] = []
    @State private var showingCalculation = false
    @State private var purchaseList: [Product] = []
    @State private var pendingList: [Product] = []
    @State private var clientName: String = ""
    @State private var clientOrders: [ClientOrder] = []
    @State private var showClientNameField = false
    
    // Cores personalizadas
    private let primaryColor = Color(red: 0.3, green: 0.4, blue: 0.9)
    private let secondaryColor = Color(red: 0.9, green: 0.3, blue: 0.4)
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient
                
                VStack(spacing: 0) {
                    // Header com título
                    headerView
                    
                    // Conteúdo principal
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            // Seção de seleção de produto
                            productSelectionSection
                            
                            // Seção de preços
                            priceDisplaySection
                            
                            // Seção de quantidade
                            quantityInputSection
                            
                            // Botões de ação
                            actionButtonsSection
                            
                            // Seção de pedidos
                            if !orders.isEmpty {
                                ordersSection
                            }

                            if showClientNameField {
                                VStack(spacing: 12) {
                                    TextField("Nome do Cliente", text: $clientName)
                                        .textFieldStyle(.roundedBorder)

                                    Button("Salvar Pedido e Gerar Mensagem") {
                                        let clientOrder = ClientOrder(clientName: clientName, items: orders)
                                        clientOrders.append(clientOrder)

                                        // Limpar dados
                                        orders.removeAll()
                                        quantityKg = ""
                                        clientName = ""
                                        showingCalculation = false
                                        showClientNameField = false

                                        self.openWhatsApp(with: clientOrder)
                                    }
                                    .buttonStyle(.borderedProminent)
                                }
                            }
                            
                            // Seção de sugestão de compra
                            purchaseSuggestionsSection
                            
                            // Resumo financeiro
                            if !orders.isEmpty {
                                financialSummarySection
                            }
                        }
                        .padding(.top, 6)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Background
    private var backgroundGradient: some View {
        Group {
            if #available(iOS 18.0, *) {
                MeshGradient(
                    width: 3,
                    height: 4,
                    points: [
                        .init(0, 0), .init(0.5, 0), .init(1, 0),
                        .init(0, 0.3), .init(0.5, 0.3), .init(1, 0.3),
                        .init(0, 0.7), .init(0.5, 0.7), .init(1, 0.7),
                        .init(0, 1), .init(0.5, 1), .init(1, 1)
                    ],
                    colors: [
                        Color(red: 0.95, green: 0.85, blue: 0.9).opacity(0.8),
                        Color(red: 0.85, green: 0.9, blue: 0.95).opacity(0.8),
                        Color(red: 0.9, green: 0.95, blue: 0.85).opacity(0.8),
                        Color(red: 0.9, green: 0.8, blue: 0.95).opacity(0.8),
                        Color(red: 0.8, green: 0.95, blue: 0.9).opacity(0.8),
                        Color(red: 0.95, green: 0.9, blue: 0.8).opacity(0.8),
                        Color(red: 0.85, green: 0.8, blue: 0.9).opacity(0.8),
                        Color(red: 0.9, green: 0.85, blue: 0.95).opacity(0.8),
                        Color(red: 0.8, green: 0.9, blue: 0.85).opacity(0.8),
                        Color(red: 0.95, green: 0.8, blue: 0.85).opacity(0.8),
                        Color(red: 0.8, green: 0.85, blue: 0.95).opacity(0.8),
                        Color(red: 0.9, green: 0.9, blue: 0.8).opacity(0.8)
                    ]
                )
                .ignoresSafeArea()
            } else {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.95, green: 0.85, blue: 0.9).opacity(0.8),
                        Color(red: 0.85, green: 0.9, blue: 0.95).opacity(0.8)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            }
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "bag.fill")
                    .font(.title2)
                    .foregroundColor(primaryColor)
                
                Text("Pedido Fácil")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: clearAllOrders) {
                    Image(systemName: "trash.fill")
                        .font(.title3)
                        .foregroundColor(.red)
                }
                .disabled(orders.isEmpty)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            Divider()
                .padding(.horizontal, 20)
        }
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Product Selection Section
    private var productSelectionSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "cart.fill")
                    .foregroundColor(primaryColor)
                Text("Selecionar Produto")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            Menu {
                ForEach(sampleProducts.sorted(by: { $0.category < $1.category })) { product in
                    Button(action: {
                        selectedProduct = product
                        withAnimation(.spring()) {
                            showingCalculation = false
                        }
                    }) {
                        VStack(alignment: .leading) {
                            Text("\(product.name)  \(product.brand ?? "")")
                            if let brand = product.brand {
                                Text(brand)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Text(product.category)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(selectedProduct.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if let brand = selectedProduct.brand {
                            Text(brand)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Text(selectedProduct.category)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.up.chevron.down")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
    }
    
    // MARK: - Price Display Section
    private var priceDisplaySection: some View {
        HStack(spacing: 16) {
            VStack(spacing: 8) {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
                
                Text("Compra")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("R$ \(selectedProduct.purchasePrice, specifier: "%.2f")")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("por \(selectedProduct.packageSize)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            
            VStack(spacing: 8) {
                Image(systemName: "banknote.fill")
                    .font(.title2)
                    .foregroundColor(.green)
                
                Text("Venda")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("R$ \(selectedProduct.sellingPrice, specifier: "%.2f")")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("por \(selectedProduct.packageSize)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            
            VStack(spacing: 8) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.title2)
                    .foregroundColor(secondaryColor)
                
                Text("Margem")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("R$ \(selectedProduct.sellingPrice - selectedProduct.purchasePrice, specifier: "%.2f")")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("\(((selectedProduct.sellingPrice - selectedProduct.purchasePrice) / selectedProduct.purchasePrice * 100), specifier: "%.1f")%")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }
    
    // MARK: - Quantity Input Section
    private var quantityInputSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "scalemass.fill")
                    .foregroundColor(primaryColor)
                Text("Quantidade")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            TextField("0.00", text: $quantityKg)
                .keyboardType(.decimalPad)
                .font(.title2)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(primaryColor.opacity(0.3), lineWidth: 1)
                )
            
            Text("Digite a quantidade em kg")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Action Buttons Section
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            Button(action: calculate) {
                HStack {
                    Image(systemName: "calculator.fill")
                        .font(.title3)
                    Text("Calcular")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        colors: [primaryColor, primaryColor.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(quantityKg.isEmpty)
            
            if showingCalculation {
                calculationResultView
                    .transition(.move(edge: .top).combined(with: .opacity))
                
                Button(action: addOrder) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                        Text("Adicionar ao Pedido")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            colors: [secondaryColor, secondaryColor.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
    
    // MARK: - Calculation Result View
    private var calculationResultView: some View {
        VStack(spacing: 12) {
            Text("Resultado do Cálculo")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text("Total")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("R$ \(totalPrice, specifier: "%.2f")")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                
                VStack(spacing: 4) {
                    Text("Lucro")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("R$ \(totalProfit, specifier: "%.2f")")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Orders Section
    private var ordersSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "list.clipboard.fill")
                    .foregroundColor(primaryColor)
                Text("Pedidos (\(orders.count))")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            LazyVStack(spacing: 12) {
                ForEach(orders) { order in
                    orderItemView(order: order)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Order Item View
    private func orderItemView(order: OrderItem) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(order.product.name)
                    .font(.headline)
                    .fontWeight(.medium)
                
                if let brand = order.product.brand {
                    Text(brand)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text("\(order.quantity, specifier: "%.2f") kg")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("R$ \(order.totalPrice, specifier: "%.2f")")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text("Lucro: R$ \(order.totalProfit, specifier: "%.2f")")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                removeOrder(order)
            } label: {
                Label("Excluir", systemImage: "trash.fill")
            }
        }
    }
    
    // MARK: - Purchase Suggestions Section
    private var purchaseSuggestionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📦 Lista de Compras Sugerida")
                .font(.headline)
            
            if purchaseList.isEmpty {
                Text("Nenhum produto ainda atingiu a quantidade mínima de compra.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                ForEach(purchaseList) { product in
                    Text("🟢 \(product.name) \(product.brand ?? "") – comprar \(product.calculatedUnits ?? 1) \(product.packageType)")
                        .font(.subheadline)
                }
            }
            
            Divider()
            
            Text("⏳ Produtos em Espera")
                .font(.headline)
            
            if pendingList.isEmpty {
                Text("Nenhum produto aguardando nova demanda.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                ForEach(pendingList) { product in
                    let totalKg = orders
                        .filter { $0.product == product }
                        .map { $0.quantity }
                        .reduce(0, +)
                    let sobraKg = totalKg.truncatingRemainder(dividingBy: Double(product.unitsPerPackage))
                    
                    Text("🟡 \(product.name) \(product.brand ?? "") – espera: \(sobraKg, specifier: "%.2f")kg")
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Financial Summary Section
    private var financialSummarySection: some View {
        VStack(spacing: 16) {
            Text("Resumo Financeiro")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 20) {
                VStack(spacing: 8) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.title)
                        .foregroundColor(.blue)
                    
                    Text("Total Vendas")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("R$ \(orders.reduce(0) { $0 + $1.totalPrice }, specifier: "%.2f")")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                
                VStack(spacing: 8) {
                    Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                        .font(.title)
                        .foregroundColor(.green)
                    
                    Text("Total Lucro")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("R$ \(orders.reduce(0) { $0 + $1.totalProfit }, specifier: "%.2f")")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Functions
    func calculate() {
        guard let kg = Double(quantityKg) else {
            print("Quantidade inválida")
            return
        }
        
        totalPrice = kg * selectedProduct.sellingPrice
        totalProfit = kg * (selectedProduct.sellingPrice - selectedProduct.purchasePrice)
        
        withAnimation(.spring()) {
            showingCalculation = true
        }
    }
    
    func addOrder() {
        guard let quantity = Double(quantityKg), quantity > 0 else {
            print("❌ Quantidade inválida")
            return
        }
        
        let newOrder = OrderItem(product: selectedProduct, quantity: quantity)
        withAnimation(.spring()) {
            orders.append(newOrder)
            generatePurchaseSuggestions()
        }
        
        // Limpar campos
        quantityKg = ""
        showingCalculation = false
        showClientNameField = true
    }
    
    func removeOrder(_ order: OrderItem) {
        withAnimation(.spring()) {
            orders.removeAll { $0.id == order.id }
        }
    }
    
    func clearAllOrders() {
        withAnimation(.spring()) {
            orders.removeAll()
        }
    }
    
    
    func generatePurchaseSuggestions() {
        // 1. Dicionário para somar quantidade por produto
        var demandMap: [Product: Double] = [:]
        
        // 2. Agrupa os pedidos
        for order in orders {
            demandMap[order.product, default: 0.0] += order.quantity
        }
        
        // 3. Limpa listas atuais
        purchaseList.removeAll()
        pendingList.removeAll()
        
        // 4. Verifica cada produto
        for (product, totalKg) in demandMap {
            let kgPorUnidade = Double(product.unitsPerPackage)
            let totalEmbalagens = totalKg / kgPorUnidade
            let embalagensInteiras = Int(totalEmbalagens) // arredonda pra baixo
            
            if embalagensInteiras >= 1 {
                var produtoComQtd = product
                produtoComQtd.calculatedUnits = embalagensInteiras
                purchaseList.append(produtoComQtd)
            }
            
            let sobraKg = totalKg.truncatingRemainder(dividingBy: kgPorUnidade)
            if sobraKg > 0 {
                pendingList.append(product)
            }
        }
    }
    // MARK: - WhatsApp & Mensagem
    func generateMessage(for order: ClientOrder) -> String {
        var message = "📦 Pedido de \(order.clientName):\n\n"
        for item in order.items {
            let brandString = item.product.brand ?? ""
            message += "\n - \(item.product.name) \(brandString): \(String(format: "%.2f", item.quantity))kg"
        }
        message += "\n💰 Total: R$ \(String(format: "%.2f", order.totalPrice))"
        message += "\n📈 Lucro: R$ \(String(format: "%.2f", order.totalProfit))"
        return message
    }

    func generateReceipt(for order: ClientOrder) -> String {
        var receipt = ""
        
        receipt += "📦 Pedido para: \(order.clientName)\n"
        receipt += "------------------------------\n"
        
        for item in order.items {
            receipt += "- \(item.product.name) \(item.product.brand ?? "")\n"
            receipt += "  Quantidade: \(String(format: "%.2f", item.quantity)) kg\n"
            receipt += "  Preço unitário: R$ \(String(format: "%.2f", item.product.sellingPrice))\n"
            receipt += "  Total: R$ \(String(format: "%.2f", item.totalPrice))\n\n"
        }
        
        receipt += "------------------------------\n"
        receipt += "💰 Total a pagar: R$ \(String(format: "%.2f", order.totalPrice))\n"
        receipt += "------------------------------\n"
        receipt += "Obrigado pela preferência! 🙏\n"
        
        return receipt
    }
    
    func openWhatsApp(with order: ClientOrder) {
        let text = generateMessage(for: order)
        let encodedText = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let whatsappURL = URL(string: "whatsapp://send?text=\(encodedText)")!
        #if os(iOS)
        if UIApplication.shared.canOpenURL(whatsappURL) {
            UIApplication.shared.open(whatsappURL)
        } else {
            // Handle the error (e.g., show an alert)
        }
        #endif
    }
}

#Preview {
    if #available(iOS 26.0, *) {
        ContentView()
    } else {
        Text("Preview not available")
    }
}

