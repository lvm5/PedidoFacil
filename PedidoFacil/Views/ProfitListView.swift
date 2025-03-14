import SwiftUI

struct ProfitListView: View {
    @ObservedObject var coordinator: AppCoordinator

    var body: some View {
        VStack {
            Text("💰 Lista de Lucro por Pedido")
                .font(.title)
                .padding()
            Spacer()
        }
        .navigationTitle("Lucro por Pedido")
    }
}