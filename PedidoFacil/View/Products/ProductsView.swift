import SwiftUI

@available(iOS 26.0, *)
struct ProductsView: View {
    @EnvironmentObject var productModel: ProductModel
    @State private var showingAddProduct = false
    @State private var selectedProduct: Product?
    @State private var searchText = ""
    
    var filteredProducts: [Product] {
        if searchText.isEmpty {
            return productModel.products
        } else {
            return productModel.products.filter { product in
                product.name.localizedCaseInsensitiveContains(searchText) ||
                product.category.localizedCaseInsensitiveContains(searchText) ||
                (product.brand?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(filteredProducts.sorted(by: { $0.category < $1.category })) { product in
                        ProductRowView(product: product, secondaryColor: Color.blue)
                            .onTapGesture {
                                selectedProduct = product
                            }
                    }
                }
                .searchable(text: $searchText, prompt: "Buscar produtos...")
            }
            .navigationTitle("Produtos")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddProduct = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddProduct) {
                ProductEditView()
            }
            .sheet(item: $selectedProduct) { product in
                ProductEditView(product: product)
            }
        }
    }
}

#Preview {
    if #available(iOS 26.0, *) {
        ProductsView()
            .environmentObject(ProductModel())
    } else {
        // Fallback on earlier versions
    }
}
