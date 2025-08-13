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
    
    @Dependency(\.date.now) var now
    
    @ObservableState
    public struct State: Equatable {
        let detailType: DetailType
        @FetchAll var reminderRows: [Row]
        @Shared var showCompleted: Bool
        public init(detailType: DetailType) {
            self.detailType = detailType
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
        
        private var remindersQuery: some StructuredQueriesCore.Statement<Row> {
            Reminder
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
        case view(View)
        
        public enum View {
            case onTask
        }
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(.onTask):
                return .none
            }
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
                    tags: row.tags
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
                    Image(systemName: "chevron.left") // 只显示箭头
                        .font(.headline)
                        .foregroundStyle(store.detailType.color.gradient)
                }
            }
            
            if store.detailType.is(\.remindersList) {
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                      Button {
                        
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
