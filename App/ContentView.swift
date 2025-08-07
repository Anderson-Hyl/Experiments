import SwiftUI
import SQLHub

struct ContentView: View {
    var body: some View {
        Form {
            NavigationLink {
                FactsView()
            } label: {
                Text("Facts Experiment")
            }
            .foregroundStyle(.primary)
        }
        .navigationTitle("Experiments")
    }
}

#Preview {
    ContentView()
}
