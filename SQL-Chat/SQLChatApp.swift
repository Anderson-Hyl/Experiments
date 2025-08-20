import SwiftUI
import ComposableArchitecture
import SharingGRDB
import SQLHub

@main
struct SQLChatApp: App {
    static let chatMainStore = Store(
        initialState: ChatMainReducer.State(),
        reducer: { ChatMainReducer() }
    )
    init() {
        prepareDependencies {
            $0.defaultDatabase = try! applicationDB()
        }
    }
    var body: some Scene {
        WindowGroup {
            ChatMainView(
                store: Self.chatMainStore
            )
        }
    }
}
