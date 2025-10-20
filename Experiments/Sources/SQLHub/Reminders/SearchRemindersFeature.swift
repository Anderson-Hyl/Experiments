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
    
    private enum SearchTaskID { case searchDebounce }

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(\.searchText):
                guard !state.searchText.isEmpty else {
                    return .cancel(id: SearchTaskID.searchDebounce)
                }
                return .run { [searchText = state.searchText, reminders = state.$reminders] send in
                    try await Task.sleep(for: .milliseconds(300))
                    try await reminders.load(
                        Reminder.where { reminder in
                            for term in searchText.split(separator: " ") {
                                reminder.title.contains(term) || reminder.notes.contains(term)
                            }
                        }
                    )
                }
                .cancellable(id: SearchTaskID.searchDebounce, cancelInFlight: true)
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
            ReminderRowView(
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
