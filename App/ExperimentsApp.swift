import SwiftUI
import SQLHub
import SharingGRDB

@main
struct ExperimentsApp: App {
    init() {
        prepareDependencies {
            $0.defaultDatabase = try! applicationDB()
        }
    }
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
            }
        }
    }
}
