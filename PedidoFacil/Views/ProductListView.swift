import SwiftUI

struct ProductListView: View {
    @ObservedObject var coordinator: AppCoordinator

    var body: some View {
        VStack {
            Text("📦 Lista de Produtos")
                .font(.title)
                .padding()
            Spacer()
        }
        .navigationTitle("Produtos")
    }
}