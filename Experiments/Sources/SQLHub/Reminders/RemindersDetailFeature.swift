import ComposableArchitecture
import SharingGRDB
import SwiftUI
import Utils

@Reducer
public struct RemindersDetailReducer {
    
    @CasePathable
    @dynamicMemberLookup
    public enum DetailType: Hashable {
        case all
        case completed
        case flagged
        case remindersList(RemindersList)
        case scheduled
        case tags([Tag])
        case today
        
        var title: String {
            switch self {
            case .all: "All"
            case .completed: "Completed"
            case .flagged: "Flagged"
            case let .remindersList(remindersList): remindersList.title
            case .scheduled: "Scheduled"
            case .tags: "Tags"
            case .today: "Today"
            }
        }
        
        var color: Color {
            switch self {
            case .all: .primary
            case .completed: Color(hex: 0x6FBF5F)
            case .flagged: Color(hex: 0xE66D74)
            case let .remindersList(remindersList): remindersList.color
            case .scheduled: Color(hex: 0x5E79E6)
            case .tags: Color(hex: 0x3DAE83)
            case .today: Color(hex: 0x2FB59B)
            }
        }
    }
    
    @CasePathable
    @dynamicMemberLookup
    public enum Ordering: String, CaseIterable, Sendable {
        case dueDate = "Due Date"
        case manual = "Manual"
        case priority = "Priority"
        case title = "Title"
        
        var icon: Image {
            switch self {
            case .dueDate: Image(systemName: "calendar")
            case .manual: Image(systemName: "hand.draw")
            case .priority: Image(systemName: "chart.bar.fill")
            case .title: Image(systemName: "textformat.characters")
            }
        }
    }
    
    @Dependency(\.date.now) var now
    
    @Reducer(state: .equatable)
    public enum Destination {
        case reminderForm(ReminderFormReducer)
    }
    
    @ObservableState
    public struct State: Equatable {
        let detailType: DetailType
        @FetchAll var reminderRows: [Row]
        @Shared var showCompleted: Bool
        @Shared var ordering: Ordering
        @Presents var destination: Destination.State?
        @Presents var alert: AlertState<Action.Alert>?
        public init(detailType: DetailType) {
            self.detailType = detailType
            _ordering = Shared(
                wrappedValue: .dueDate,
                .appStorage("ordering_list_\(detailType.id)")
            )
            _showCompleted = Shared(
                wrappedValue: detailType == .completed,
                .appStorage("show_completed_list_\(detailType.id)")
            )
            _reminderRows = FetchAll(remindersQuery)
        }
        
        @Selection
        public struct Row: Identifiable, Equatable, Sendable {
            public var id: Reminder.ID { reminder.id }
            let reminder: Reminder
            let remindersList: RemindersList
            let isPastDue: Bool
            let notes: String
            @Column(as: [String].JSONRepresentation.self)
            let tags: [String]
        }
        
        fileprivate var remindersQuery: some StructuredQueriesCore.Statement<Row> & Sendable {
            Reminder
                .where {
                    if !showCompleted {
                        !$0.isCompleted
                    }
                }
                .order { $0.isCompleted }
                .order {
                    switch ordering {
                    case .dueDate: $0.dueDate.asc(nulls: .last)
                    case .manual: $0.position
                    case .priority: ($0.priority.desc(), $0.isFlagged.desc())
                    case .title: $0.title
                    }
                }
                .withTags
                .where { reminder, _, tag in
                    switch detailType {
                    case .all: true
                    case .completed: reminder.isCompleted
                    case .flagged: reminder.isFlagged
                    case .remindersList(let remindersList): reminder.remindersListID.eq(remindersList.id)
                    case .scheduled: reminder.isScheduled
                    case .tags(let tags): tag.id.ifnull(UUID(0)).in(tags.map(\.id))
                    case .today: reminder.isToday
                    }
                }
                .join(RemindersList.all) { $0.remindersListID.eq($3.id) }
                .select {
                    Row.Columns(
                        reminder: $0,
                        remindersList: $3,
                        isPastDue: $0.isPastDue,
                        notes: $0.notes,
                        tags: #sql("\($2.jsonNames)")
                    )
                }
        }
    }
    
    @CasePathable
    public enum Action: ViewAction {
        case alert(PresentationAction<Alert>)
        case destination(PresentationAction<Destination.Action>)
        case dismissAlert(fetchReminders: Bool)
        case view(View)
        
        public enum View {
            case onTask
            case onTappedShowCompletedButton
            case onTappedOrderingButton(Ordering)
            case onTappedNewReminderButton
            case onTappedEditReminderButton(Reminder)
            case onTappedDeleteReminderButton(Reminder)
            case onTappedToggleReminderFlagButton(Reminder)
        }
        
        public enum Alert: Equatable {
            case confirmDelete(Reminder)
            case cancelDelete
        }
    }
    
    public var body: some ReducerOf<Self> {
        Reduce {
            state,
            action in
            switch action {
            case let .alert(.presented(.confirmDelete(reminder))):
                return .run { [reminder] send in
                    @Dependency(\.defaultDatabase) var database
                    try await database.write { db in
                        try Reminder.delete(reminder).execute(db)
                    }
                    await send(.dismissAlert(fetchReminders: true))
                }
            case .alert(.presented(.cancelDelete)):
                return .send(.dismissAlert(fetchReminders: false))
            case .alert:
                return .none
            case .destination:
                return .none
            case let .dismissAlert(fetchReminders):
                state.alert = nil
                guard fetchReminders else {
                    return .none
                }
                return updateQuery(state: &state)
            case .view(.onTask):
                return .none
            case .view(.onTappedShowCompletedButton):
                state.$showCompleted.withLock {
                    $0.toggle()
                }
                return updateQuery(state: &state)
            case let .view(.onTappedOrderingButton(ordering)):
                state.$ordering.withLock {
                    $0 = ordering
                }
                return updateQuery(state: &state)
            case .view(.onTappedNewReminderButton):
                guard case let .remindersList(remindersList) = state.detailType else {
                    return .none
                }
                state.destination = .reminderForm(
                    ReminderFormReducer.State(
                        reminder: Reminder.Draft(remindersListID: remindersList.id),
                        remindersList: remindersList,
                    )
                )
                return .none
            case let .view(.onTappedEditReminderButton(reminder)):
                guard let remindersList = state.reminderRows.first(where: { $0.id == reminder.id })?.remindersList else {
                    return .none
                }
                state.destination = .reminderForm(
                    ReminderFormReducer.State(
                        reminder: Reminder.Draft(reminder),
                        remindersList: remindersList,
                    )
                )
                return .none
                
            case let .view(.onTappedDeleteReminderButton(reminder)):
                state.alert = AlertState(
                    title: {
                        TextState("Delete this reminder?")
                    },
                    actions: {
                        ButtonState(role: .cancel, action: .cancelDelete) {
                            TextState("Cancel")
                        }
                        ButtonState(role: .destructive, action: .confirmDelete(reminder)) {
                            TextState("Delete")
                        }
                    }
                )
                return .none
            case let .view(.onTappedToggleReminderFlagButton(reminder)):
                let toggleFlagAction: Effect<Action> = .run { [reminder] _ in
                    @Dependency(\.defaultDatabase) var database
                    try database.write { db in
                        try Reminder
                            .find(reminder.id)
                            .update { $0.isFlagged.toggle() }
                            .execute(db)
                    }
                }
                return toggleFlagAction
            }
        }
        .ifLet(\.$destination, action: \.destination)
        .ifLet(\.$alert, action: \.alert)
    }
    
    private func updateQuery(state: inout State) -> Effect<Action> {
        .run { [rows = state.$reminderRows, remindersQuery = state.remindersQuery] _ in
            try await rows.load(remindersQuery, animation: .default)
        }
    }
}

@ViewAction(for: RemindersDetailReducer.self)
public struct RemindersDetailView: View {
    @Bindable public var store: StoreOf<RemindersDetailReducer>
    @Environment(\.dismiss) var dismiss
    public init(store: StoreOf<RemindersDetailReducer>) {
        self.store = store
    }
    public var body: some View {
        List {
            ForEach(store.reminderRows) { row in
                ReminderRow(
                    color: store.detailType.color,
                    isPastDue: row.isPastDue,
                    notes: row.notes,
                    reminder: row.reminder,
                    remindersList: row.remindersList,
                    showCompleted: true,
                    tags: row.tags,
                    editAction: {
                        send(.onTappedEditReminderButton(row.reminder))
                    },
                    deleteAction: {
                        send(.onTappedDeleteReminderButton(row.reminder))
                    },
                    toggleFlagAction: {
                        send(.onTappedToggleReminderFlagButton(row.reminder))
                    },
                )
            }
        }
        .listStyle(.plain)
        .task {
            await send(.onTask).finish()
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(store.detailType.title)
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(store.detailType.color.gradient)
            }
            
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .foregroundStyle(store.detailType.color.gradient)
                }
            }
            
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Group {
                        Menu {
                            ForEach(RemindersDetailReducer.Ordering.allCases, id: \.self) { ordering in
                                Button {
                                    send(.onTappedOrderingButton(ordering))
                                } label: {
                                    Text(ordering.rawValue)
                                    ordering.icon
                                }
                            }
                        } label: {
                            Text("Sort By")
                            Text(store.ordering.rawValue)
                            Image(systemName: "arrow.up.arrow.down")
                        }
                        Button {
                            send(.onTappedShowCompletedButton)
                        } label: {
                            Text(store.showCompleted ? "Hide Completed" : "Show Completed")
                            Image(systemName: store.showCompleted ? "eye.slash.fill" : "eye")
                        }
                    }
                    .tint(store.detailType.color)
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
            
            if store.detailType.is(\.remindersList) {
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                      Button {
                          send(.onTappedNewReminderButton)
                      } label: {
                        HStack {
                          Image(systemName: "plus.circle.fill")
                          Text("New Reminder")
                        }
                        .bold()
                        .font(.title3)
                      }
                      Spacer()
                    }
                    .foregroundStyle(store.detailType.color.gradient)
                }
            }
        }
        .sheet(
            item: $store.scope(
                state: \.destination?.reminderForm,
                action: \.destination.reminderForm
            )
        ) { reminderFormStore in
            NavigationStack {
                ReminderForm(store: reminderFormStore)
            }
        }
        .alert($store.scope(state: \.alert, action: \.alert))
        .navigationBarBackButtonHidden()
    }
}

extension RemindersDetailReducer.DetailType {
    public var id: String {
        switch self {
        case .all: "all"
        case .completed: "completed"
        case .flagged: "flagged"
        case .remindersList(let remindersList): "list_\(remindersList.id)"
        case .scheduled: "scheduled"
        case .tags: "tags"
        case .today: "today"
        }
    }
}
