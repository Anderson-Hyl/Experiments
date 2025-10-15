import SwiftUI
import SQLHub
import ChartsHub
import SwiftUIHub
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
                SwiftUIHubView()
            } label: {
                Text("SwiftUI Experiment")
            }
        }
        .foregroundStyle(.primary)
        .navigationTitle("Experiments")
    }
}

#Preview {
    ContentView()
}
