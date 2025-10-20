import ComposableArchitecture
import Foundation
import SharingGRDB
import SwiftUI

@Reducer
public struct SearchRemindersReducer {

    @ObservableState
    public struct State: Equatable {
        var searchText = ""
        @FetchAll var reminders: [Reminder]
        public init(searchText: String = "", reminders: [Reminder] = []) {
            self.searchText = searchText
            self._reminders = FetchAll(wrappedValue: reminders)
        }
    }

    public enum Action: BindableAction, ViewAction {
        case binding(BindingAction<State>)
        case view(View)

        public enum View {
            
        }
    }

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(\.searchText):
                if !state.searchText.isEmpty {
                    return .run { [reminders = state.$reminders] send in
                        try await reminders.load()
                    }
                }
                return .none
            case .binding:
                return .none
            case .view:
                return .none
            }
        }
    }
}

@ViewAction(for: SearchRemindersReducer.self)
public struct SearchRemindersView: View {
    @Bindable public var store: StoreOf<SearchRemindersReducer>
    public init(store: StoreOf<SearchRemindersReducer>) {
        self.store = store
    }
    public var body: some View {
        ForEach(store.reminders) { reminder in
            ReminderRow(
                color: .blue,
                isPastDue: false,
                notes: "",
                reminder: reminder,
                showCompleted: false,
                tags: [],
                editAction: {},
                deleteAction: {},
                toggleFlagAction: {}
            )
        }
    }
}

struct SearchRemindersPreviews: PreviewProvider {
    static var previews: some View {
        Content(
            store: Store(
                initialState: SearchRemindersReducer.State(),
                reducer: { SearchRemindersReducer() }
            )
        )
    }

    struct Content: View {
        @Bindable var store: StoreOf<SearchRemindersReducer>
        init(store: StoreOf<SearchRemindersReducer>) {
            let _ = try! prepareDependencies {
                $0.defaultDatabase = try applicationDB()
            }
            self.store = store
        }
        var body: some View {
            NavigationStack {
                List {
                    if store.searchText.isEmpty {
                        Text(#"Tap "Search"..."#)
                    } else {
                        SearchRemindersView(store: store)
                    }
                }
                .searchable(text: $store.searchText)
            }
        }
    }
}
