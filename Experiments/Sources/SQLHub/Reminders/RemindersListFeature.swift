import ComposableArchitecture
import SwiftUI
import SharingGRDB
import HeatMap

@Reducer
public struct RemindersListReducer {
    public init() {}
    
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
        
        public init() {}
        
        @Selection
        struct RemindersListState: Identifiable, Equatable {
            var id: RemindersList.ID { remindersList.id }
            var remindersCount: Int
            var remindersList: RemindersList
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

extension RemindersListReducer.State.RemindersListState: HeatMapValue {
    var heat: Double {
        Double(remindersCount)
    }
}


@ViewAction(for: RemindersListReducer.self)
public struct RemindersListView: View {
    public let store: StoreOf<RemindersListReducer>
    public init(store: StoreOf<RemindersListReducer>) {
        self.store = store
    }
    public var body: some View {
        ScrollView {
            HeatMapView(items: store.remindersList) { reminderListState, normalized in
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
            }
            .padding()
            .frame(height: 400)
        }
        .task {
            await send(.onTask).finish()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Reminders")
    }
}
