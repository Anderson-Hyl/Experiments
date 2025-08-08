import SwiftUI
import SQLHub
import ComposableArchitecture

struct ContentView: View {
    var body: some View {
        Form {
            NavigationLink {
                FactsView()
            } label: {
                Text("Facts Experiment")
            }
            
            
            NavigationLink {
                RemindersListView(
                    store: Store(
                        initialState: RemindersListReducer.State(),
                        reducer: { RemindersListReducer() }
                    )
                )
            } label: {
                Text("Reminders Experiment")
            }
        }
        .foregroundStyle(.primary)
        .navigationTitle("Experiments")
    }
}

#Preview {
    ContentView()
}
