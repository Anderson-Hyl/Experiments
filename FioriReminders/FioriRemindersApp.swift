import SwiftUI
import ComposableArchitecture
import SharingGRDB
import SQLHub


@main
struct FioriRemindersApp: App {
    static let fioriRemindersListStore = Store(
        initialState: RemindersListReducer.State(),
        reducer: { RemindersListReducer() }
    )
    init() {
        prepareDependencies {
            $0.defaultDatabase = try! applicationDB()
        }
    }
    var body: some Scene {
        WindowGroup {
            FioriRemindersListView(store: Self.fioriRemindersListStore)
        }
    }
}
