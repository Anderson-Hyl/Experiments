import ComposableArchitecture
import SwiftUI
import SharingGRDB
import HeatMap

@Reducer
public struct RemindersListReducer {
    public init() {}
    
    @Reducer(state: .equatable)
    public enum Destination {
        case reminderForm(ReminderFormReducer)
    }
    
    @ObservableState
    public struct State: Equatable {
        @FetchAll(
            RemindersList
                .group(by: \.id)
                .order(by: \.position)
                .leftJoin(Reminder.all) {
                    $0.id.eq($1.remindersListID) && !$1.isCompleted
                }
                .select {
                    RemindersListState.Columns(
                        remindersCount: $1.id.count(),
                        remindersList: $0
                    )
                },
            animation: .default
        ) var remindersList
        
        @Presents
        var destination: Destination.State?
        
        public init() {}
        
        @Selection
        public struct RemindersListState: Identifiable, Equatable {
            public var id: RemindersList.ID { remindersList.id }
            public var remindersCount: Int
            public var remindersList: RemindersList
        }
    }
    
    @CasePathable
    public enum Action: ViewAction {
        case view(View)
        case destination(PresentationAction<Destination.Action>)
        
        public enum View {
            case onTask
            case onTapRemindersList(RemindersList.ID)
            case onTapNewReminder
        }
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .destination:
                return .none
            case .view(.onTask):
                return .none
            case .view(.onTapRemindersList): // TODO: push to reminders list
                return .none
            case .view(.onTapNewReminder):
                guard let remindersList = state.remindersList.map(\.remindersList).first else {
                    reportIssue("There must be at least one list.")
                    return .none
                }
                state.destination = .reminderForm(
                    ReminderFormReducer.State(
                        reminder: Reminder.Draft(remindersListID: remindersList.id),
                        remindersList: remindersList,
                    )
                )
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension RemindersListReducer.State.RemindersListState: HeatMapValue {
    public var heat: Double {
        Double(remindersCount)
    }
}


@ViewAction(for: RemindersListReducer.self)
public struct RemindersListView: View {
    @Bindable
    public var store: StoreOf<RemindersListReducer>
    
    @State
    private var remindersListForm: RemindersList.Draft?
    
    public init(store: StoreOf<RemindersListReducer>) {
        self.store = store
    }
    public var body: some View {
        List {
            Section {
                remindersListHeatMap
                    .padding(.horizontal, -20)
            }
        }
        .listStyle(.insetGrouped)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                HStack {
                    Button {
                        send(.onTapNewReminder)
                    } label: {
                        Label("New Reminder", systemImage: "plus.circle.fill")
                            .labelStyle(.titleAndIcon)
                            .bold()
                            .font(.title3)
                    }
                    
                    Spacer()
                    
                    Button {
                        remindersListForm = RemindersList.Draft()
                    } label: {
                        Text("Add List")
                            .font(.title3)
                    }
                }
            }
        }
        .task {
            await send(.onTask).finish()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Reminders")
        .sheet(item: $remindersListForm) { remindersListDraft in
            NavigationStack {
                RemindersListForm(remindersList: remindersListDraft)
            }
            .presentationDetents([.medium])
        }
        .sheet(
            item: $store.scope(
                state: \.destination?.reminderForm,
                action: \.destination.reminderForm
            )
        ) { reminderFormStore in
            NavigationStack {
                ReminderForm(
                    store: reminderFormStore
                )
                .navigationTitle("New Reminder")
            }
        }
    }
    
    private var remindersListHeatMap: some View {
        HeatMapView(items: store.remindersList, spacing: 2) { reminderListState, normalized in
            RemindersListHeatMapCell(
                reminderListState: reminderListState,
                normalized: normalized
            ) {
                send(.onTapRemindersList(reminderListState.remindersList.id))
            }
        }
        .listRowBackground(Color.clear)
        .frame(height: 400)
    }
}


public struct RemindersListHeatMapCell: View {
    let reminderListState: RemindersListReducer.State.RemindersListState
    let normalized: Double
    let onTapRemindersList: () -> Void
    public init(
        reminderListState: RemindersListReducer.State.RemindersListState,
        normalized: Double,
        onTapRemindersList: @escaping () -> Void,
    ) {
        self.reminderListState = reminderListState
        self.normalized = normalized
        self.onTapRemindersList = onTapRemindersList
    }
    
    public var body: some View {
        Button {
            onTapRemindersList()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(reminderListState.remindersList.color)
                    .overlay {
                        VStack {
                            Text("\(reminderListState.remindersList.title)")
                                .foregroundStyle(.white)
                                .font(.headline)
                                .bold()
                            Text("\(reminderListState.remindersCount)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white.opacity(0.8))
                                .contentTransition(.numericText())
                        }
                    }
                    .id(reminderListState.id)
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}

