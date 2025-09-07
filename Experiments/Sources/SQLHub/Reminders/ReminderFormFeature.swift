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
        
        @Shared var selectedTags: [Tag]
        
        public init(reminder: Reminder.Draft, remindersList: RemindersList) {
            self.reminder = reminder
            self._remindersList = FetchOne(
                wrappedValue: remindersList,
                RemindersList.find(remindersList.id)
            )
            self._selectedTags = Shared(value: [])
        }
    }
    
    @CasePathable
    public enum Action: ViewAction, BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case selectedTagsResult([Tag])
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
        Reduce {
            state,
            action in
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
            case let .selectedTagsResult(tags):
                state.$selectedTags.withLock {
                    $0 = tags
                }
                return .none
            case .view(.onTask):
                return .run { [reminderID = state.reminder.id] send in
                    @Dependency(\.defaultDatabase) var database
                    let selectedTags: [Tag] = try await database.read { db in
                        try Tag
                            .order(by: \.title)
                            .join(ReminderTag.all) { $0.id.eq($1.tagID) }
                            .where { $1.reminderID.is(reminderID) }
                            .select { tag, _ in tag }
                            .fetchAll(db)
                    }
                    await send(.selectedTagsResult(selectedTags))
                }
            case .view(.onTappedTags):
                state.destination = .tags(
                    TagsReducer.State(
                        selectedTags: state.$selectedTags
                    )
                )
                return .none
            case .view(.onTappedSaveButton):
                return .run { [reminder = state.reminder] send in
                    @Dependency(\.defaultDatabase) var database
                    try await database.write { db in
                        try Reminder.upsert { reminder }
                            .execute(db)
											// TODO: update `remindersTag` table
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
                            .foregroundStyle(.primary)
                        Spacer()
                        if let tagsDetail {
                            tagsDetail
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .font(.callout)
                                .foregroundStyle(.gray)
                        }
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
                        selection: $store.reminder.dueDate[coalesce: dueDate],
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
            } footer: {
                VStack {
                    if let createdAt = store.reminder.createdAt {
                        Text("CreatedAt: \(createdAt.formatted(date: .long, time: .shortened))")
                    }
                    if let updatedAt = store.reminder.updatedAt {
                        Text("UpdatedAt: \(updatedAt.formatted(date: .long, time: .shortened))")
                    }
                }
            }
            
        }
        .padding(.top, -28)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Save") {
                    send(.onTappedSaveButton)
                }
                .disabled(store.reminder.title.isEmpty)
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    send(.onTappedCancelButton)
                }
            }
        }
    }
    
    private var tagsDetail: Text? {
        guard let tag = store.selectedTags.first else { return nil }
        return store.$selectedTags.wrappedValue.dropFirst().reduce(Text("#\(tag.title)")) { result, tag in
            result + Text(" #\(tag.title)")
        }
    }
}

extension Reminder.Draft {
    fileprivate var isDateSet: Bool {
        get { dueDate != nil }
        set { dueDate = newValue ? Date() : nil }
    }
}

extension Optional {
  fileprivate subscript(coalesce coalesce: Wrapped) -> Wrapped {
    get { self ?? coalesce }
    set { self = newValue }
  }
}
