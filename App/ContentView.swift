import SwiftUI
import SQLHub
import ChartsHub
import ComposableArchitecture

struct ContentView: View {
    var body: some View {
        Form {
            NavigationLink {
                ChartsHubView()
            } label: {
                Text("Charts Experiment")
            }
            
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
            
            NavigationLink {
                SpacesListView(
                    store: Store(
                        initialState: SpacesListReducer.State(),
                        reducer: { SpacesListReducer() }
                    )
                )
            } label: {
                Text("Chats Experiment")
            }
        }
        .foregroundStyle(.primary)
        .navigationTitle("Experiments")
    }
}

#Preview {
    ContentView()
}
