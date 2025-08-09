import SwiftUI
import SharingGRDB
import IssueReporting
import ComposableArchitecture

@Reducer
public struct ReminderFormReducer {
    
    public init() {}
    
    @Reducer(state: .equatable)
    public enum Destination {
        case tags(TagsReducer)
    }
    
    @ObservableState
    public struct State: Equatable {
        @FetchAll(RemindersList.order(by: \.title))
        var remindersLists
        @FetchOne
        var remindersList: RemindersList
        @Presents var destination: Destination.State?
        var reminder: Reminder.Draft
        var selectedTags: [Tag] = []
        
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
        case destination(PresentationAction<Destination.Action>)
        case view(View)
        
        public enum View {
            case onTask
            case onTappedTags
            case onTappedSaveButton
            case onTappedCancelButton
        }
    }
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(\.reminder.remindersListID):
                let updatedRemindersListID = state.reminder.remindersListID
                return .run { [updatedRemindersListID, remindersList = state.$remindersList] _ in
                    try await remindersList.load(RemindersList.find(updatedRemindersListID))
                }
            case .binding:
                return .none
            case .destination:
                return .none
            case .view(.onTask):
                return .none
            case .view(.onTappedTags):
                state.destination = .tags(TagsReducer.State())
                return .none
            case .view(.onTappedSaveButton):
                return .run { [reminder = state.reminder] send in
                    @Dependency(\.defaultDatabase) var database
                    try await database.write { db in
                        try Reminder.upsert { reminder }
                            .execute(db)
                    }
                    await send(.view(.onTappedCancelButton))
                }
            case .view(.onTappedCancelButton):
                return .run { _ in
                    @Dependency(\.dismiss) var dismiss
                    await dismiss()
                }
            }
        }
        .ifLet(\.$destination, action: \.destination)
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
            
            Section {
                Button {
                    send(.onTappedTags)
                } label: {
                    HStack {
                        Image(systemName: "number.square.fill")
                            .font(.title)
                            .foregroundStyle(.blue.gradient)
                        Text("Tags")
                            .foregroundStyle(Color(.label))
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                }
            }
            .popover(
                item: $store.scope(
                    state: \.destination?.tags,
                    action: \.destination.tags
                )
            ) { tagsStore in
                NavigationView {
                    TagsView(store: tagsStore)
                }
            }
            
            Section {
                Toggle(isOn: $store.reminder.isDateSet) {
                    HStack {
                        Image(systemName: "calendar.circle.fill")
                          .font(.title)
                          .foregroundStyle(.red)
                        Text("Date")
                    }
                }
                if let dueDate = store.reminder.dueDate {
                    DatePicker(
                        "",
                        selection: .constant(Date()),
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .padding(.vertical, 2)
                }
            }
            
            Section {
                Toggle(isOn: $store.reminder.isFlagged) {
                    HStack {
                      Image(systemName: "flag.circle.fill")
                        .font(.title)
                        .foregroundStyle(.red)
                      Text("Flag")
                    }
                }
                Picker(selection: $store.reminder.priority) {
                    Text("None").tag(Priority?.none)
                    Divider()
                    Text("High").tag(Priority.high)
                    Text("Medium").tag(Priority.medium)
                    Text("Low").tag(Priority.low)
                } label: {
                    HStack {
                      Image(systemName: "exclamationmark.circle.fill")
                        .font(.title)
                        .foregroundStyle(.red)
                      Text("Priority")
                    }
                }
                
                Picker(selection: $store.reminder.remindersListID) {
                    ForEach(store.remindersLists) { remindersList in
                        Text(remindersList.title)
                            .tag(remindersList)
                            .buttonStyle(.plain)
                            .tag(remindersList.id)
                    }
                } label: {
                    HStack {
                      Image(systemName: "list.bullet.circle.fill")
                        .font(.title)
                        .foregroundStyle(store.remindersList.color)
                      Text("List")
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Save") {
                    send(.onTappedSaveButton)
                }
            }
            
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    send(.onTappedCancelButton)
                }
            }
        }
    }
}

extension Reminder.Draft {
    var isDateSet: Bool {
        get { dueDate != nil }
        set { dueDate = newValue ? Date() : nil }
    }
}
