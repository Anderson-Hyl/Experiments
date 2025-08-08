import SwiftUI
import SharingGRDB
import IssueReporting
import ComposableArchitecture

@Reducer
public struct ReminderFormReducer {
    
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        @FetchAll(RemindersList.order(by: \.title))
        var remindersLists
        
        @FetchOne
        var remindersList: RemindersList
        
        var reminder: Reminder.Draft
        
        public init(reminder: Reminder.Draft, remindersList: RemindersList) {
            self.reminder = reminder
            self._remindersList = FetchOne(
                wrappedValue: remindersList,
                RemindersList.find(remindersList.id)
            )
        }
    }
    
    @CasePathable
    public enum Action: ViewAction, BindableAction {
        case binding(BindingAction<State>)
        case view(View)
        
        public enum View {
            case onTask
        }
    }
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .view(.onTask):
                return .none
            }
        }
    }
}


@ViewAction(for: ReminderFormReducer.self)
public struct ReminderForm: View {
    @Bindable
    public var store: StoreOf<ReminderFormReducer>
    
    init(store: StoreOf<ReminderFormReducer>) {
        self.store = store
    }
    
    public var body: some View {
        Form {
            TextField("Title", text: $store.reminder.title)
            
            ZStack {
                if store.reminder.notes.isEmpty {
                    TextEditor(text: .constant("Notes"))
                        .foregroundStyle(.placeholder)
                        .disabled(true)
                }
                TextEditor(text: $store.reminder.notes)
            }
            .lineLimit(4)
            .padding(.horizontal, -5)
        }
    }
}
