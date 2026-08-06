//
//  ProductEditView.swift
//  PedidoFacil
//
//  Created by Manus Assistant on 2025-01-08.
//

import SwiftUI
import Foundation

struct ProductEditView: View {
    @EnvironmentObject var productModel: ProductModel
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var purchasePrice: String = ""
    @State private var sellingPrice: String = ""
    @State private var packageType: String = "Kg"
    @State private var packageSize: String = ""
    @State private var unitsPerPackage: String = "1"
    @State private var category: String = ""
    @State private var brand: String = ""
    @State private var selectedProduct: Product?
    @State private var didAppear: Bool = false
    
    let product: Product?
    let isEditing: Bool
    
    init(product: Product? = nil) {
        self.product = product
        self.isEditing = product != nil
    }
    
    var purchasePriceValue: Double { parseDecimal(purchasePrice) ?? 0 }
    var sellingPriceValue: Double { parseDecimal(sellingPrice) ?? 0 }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Informações Básicas")) {
                    TextField("Nome do produto", text: $name)
                    TextField("Definir categoria", text: $category)
                    TextField("Marca (opcional)", text: $brand)
                }
                Section(header: Text("Preços")) {
                    HStack {
                        VStack {
                        Text("Preço de compra")
                        Text(purchasePriceValue.asCurrency()).font(.caption).foregroundColor(.secondary)
                    }
                        Spacer()
                        TextField("0,00", text: $purchasePrice)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        VStack{
                            Text("Preço de venda")
                            Text(sellingPriceValue.asCurrency()).font(.caption).foregroundColor(.secondary)
                        }
                        Spacer()
                        TextField("0,00", text: $sellingPrice)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                Section(header: Text("Embalagem")) {
                    Picker("Tipo de embalagem", selection: $packageType) {
                        Text("Kg").tag("Kg")
                        Text("Unidade").tag("Unidade")
                        Text("Bloco").tag("Bloco")
                        Text("Bisnaga").tag("Bisnaga")
                        Text("Copo").tag("Copo")
                    }
                    
                    TextField("Tamanho da embalagem (ex: 1kg, 500g)", text: $packageSize)
                    
                    HStack {
                        Text("Unidades por embalagem")
                        Spacer()
                        TextField("1", text: $unitsPerPackage)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                if isEditing {
                    Section {
                        Button("Excluir Produto", role: .destructive) {
                            if let product = product {
                                productModel.delete(product)
                                dismiss()
                            }
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Editar Produto" : "Novo Produto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Salvar") {
                        saveProduct()
                    }
                    .disabled(!isFormValid)
                }
            }
            .onAppear {
                if !didAppear {
                    if isEditing, let product = product {
                        name = product.name
                        purchasePrice = String(product.purchasePrice)
                        sellingPrice = String(product.sellingPrice)
                        packageType = product.packageType ?? ""
                        packageSize = product.packageSize ?? ""
                        unitsPerPackage = product.unitsPerPackage.map { String($0) } ?? ""
                        category = product.category
                        brand = product.brand ?? ""
                    }
                    didAppear = true
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
    }
    
    private var isFormValid: Bool {
        !name.isEmpty &&
        parseDecimal(purchasePrice) != nil &&
        parseDecimal(sellingPrice) != nil &&
        Int(unitsPerPackage) != nil
    }
    
    private func saveProduct() {
        guard let purchasePriceValue = parseDecimal(purchasePrice),
              let sellingPriceValue = parseDecimal(sellingPrice),
              let unitsPerPackageValue = Int(unitsPerPackage) else {
            return
        }
        
        if isEditing, let existingProduct = product {
            var updatedProduct = existingProduct
            updatedProduct.name = name
            updatedProduct.purchasePrice = purchasePriceValue
            updatedProduct.sellingPrice = sellingPriceValue
            updatedProduct.packageType = packageType
            updatedProduct.packageSize = packageSize
            updatedProduct.unitsPerPackage = unitsPerPackageValue
            updatedProduct.category = category
            updatedProduct.brand = brand.isEmpty ? nil : brand
            updatedProduct.purchasePriceIsProvisional = false
            
            productModel.update(updatedProduct)
        } else {
            let newProduct = Product(
                name: name,
                purchasePrice: purchasePriceValue,
                sellingPrice: sellingPriceValue,
                packageType: packageType,
                packageSize: packageSize,
                unitsPerPackage: unitsPerPackageValue,
                category: category,
                brand: brand.isEmpty ? nil : brand,
                purchasePriceIsProvisional: false
            )
            
            productModel.add(newProduct)
        }
        
        dismiss()
    }

    private func parseDecimal(_ value: String) -> Double? {
        Double(value.replacingOccurrences(of: ",", with: "."))
    }
}

#Preview {
    ProductEditView()
        .environmentObject(ProductModel())
}
