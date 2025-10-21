import ComposableArchitecture
import Foundation
import SharingGRDB
import SwiftUI

@Reducer
public struct SearchRemindersReducer {

    @ObservableState
    public struct State: Equatable {
        var searchText = ""
        @FetchAll var rows: [ReminderRow]
        @FetchOne var completedCount: Int = 0
        public init(searchText: String = "", rows: [ReminderRow] = []) {
            self.searchText = searchText
            self._rows = FetchAll(wrappedValue: rows)
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
        Reduce {
            state,
            action in
            switch action {
            case .binding(\.searchText):
                guard !state.searchText.isEmpty else {
                    return .cancel(id: SearchTaskID.searchDebounce)
                }
                let query = Reminder
                    .join(RemindersList.all) { $0.remindersListID.eq($1.id) }
                    .leftJoin(ReminderTag.all) { $0.id.eq($2.reminderID) }
                    .leftJoin(Tag.all) { $2.tagID.eq($3.id) }
                    .where { [searchText = state.searchText] reminder, _, _, tag in
                        for term in searchText.split(separator: " ") {
                            reminder.title.contains(term)
                                || reminder.notes.contains(term)
                                || (tag.title ?? "").hasPrefix("\(term)")
                        }
                    }
                return .run { [rows = state.$rows, query] send in
                    try await Task.sleep(for: .milliseconds(300))
                    try await rows.load(
                        query
                            .group { reminder, _, _, _ in reminder.id }
                            .select { reminder, remindersList, _, tag in
                                ReminderRow.Columns(
                                    color: remindersList.color,
                                    reminder: reminder,
                                    isPastDue: reminder.isPastDue,
                                    notes: reminder.notes,
                                    tags: #sql("\(tag.jsonTitles)")
                                )
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
        ForEach(store.rows) { row in
            ReminderRowView(
                color: row.color.swiftUIColor,
                isPastDue: row.isPastDue,
                notes: row.notes,
                reminder: row.reminder,
                showCompleted: true,
                tags: row.tags,
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
