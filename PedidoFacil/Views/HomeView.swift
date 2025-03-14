import SwiftUI

struct HomeView: View {
    @ObservedObject var coordinator: AppCoordinator

    var body: some View {
        VStack {
            Text("🏠 Home")
                .font(.title)
                .padding()
            Spacer()
        }
        .navigationTitle("Home")
    }
}