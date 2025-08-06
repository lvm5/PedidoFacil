//
//  ProductEditView.swift
//  PedidoFacil
//
//  Created by Manus Assistant on 2025-01-08.
//

import SwiftUI

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
    
    let product: Product?
    let isEditing: Bool
    
    init(product: Product? = nil) {
        self.product = product
        self.isEditing = product != nil
        
        if let product = product {
            _name = State(initialValue: product.name)
            _purchasePrice = State(initialValue: String(product.purchasePrice))
            _sellingPrice = State(initialValue: String(product.sellingPrice))
            _packageType = State(initialValue: product.packageType)
            _packageSize = State(initialValue: product.packageSize)
            _unitsPerPackage = State(initialValue: String(product.unitsPerPackage))
            _category = State(initialValue: product.category)
            _brand = State(initialValue: product.brand ?? "")
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Informações Básicas") {
                    TextField("Nome do produto", text: $name)
                    TextField("Categoria", text: $category)
                    TextField("Marca (opcional)", text: $brand)
                }
                
                Section("Preços") {
                    HStack {
                        Text("Preço de compra")
                        Spacer()
                        TextField("0,00", text: $purchasePrice)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Preço de venda")
                        Spacer()
                        TextField("0,00", text: $sellingPrice)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section("Embalagem") {
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
        }
    }
    
    private var isFormValid: Bool {
        !name.isEmpty &&
        !category.isEmpty &&
        !packageSize.isEmpty &&
        Double(purchasePrice) != nil &&
        Double(sellingPrice) != nil &&
        Int(unitsPerPackage) != nil
    }
    
    private func saveProduct() {
        guard let purchasePriceValue = Double(purchasePrice),
              let sellingPriceValue = Double(sellingPrice),
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
                brand: brand.isEmpty ? nil : brand
            )
            
            productModel.add(newProduct)
        }
        
        dismiss()
    }
}

#Preview {
    ProductEditView()
        .environmentObject(ProductModel())
}

