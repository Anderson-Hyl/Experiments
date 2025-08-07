import SwiftUI
import SQLHub
import SharingGRDB

@main
struct ExperimentsApp: App {
    init() {
        prepareDependencies {
            $0.defaultDatabase = try! factDB()
        }
    }
    var body: some Scene {
        WindowGroup {
            FactsView()
        }
    }
}
