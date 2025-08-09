import ComposableArchitecture
import HeatMap
import SharingGRDB
import SwiftUI
import Utils

@Reducer
public struct RemindersListReducer {
    public init() {}

    @Reducer(state: .equatable)
    public enum Destination {
        case reminderForm(ReminderFormReducer)
        case remindersDetail(RemindersDetailReducer)
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

        @FetchOne(
            Reminder.select {
                Stats.Columns(
                    allCount: $0.count(filter: !$0.isCompleted),
                    flaggedCount: $0.count(filter: $0.isFlagged),
                    scheduledCount: $0.count(filter: $0.isScheduled),
                    todayCount: $0.count(filter: $0.isToday),
                    completedCount: $0.count(filter: $0.isCompleted),
                )
            }
        )
        var stats = Stats()

        public init() {}

        @Selection
        public struct RemindersListState: Identifiable, Equatable, Sendable {
            public var id: RemindersList.ID { remindersList.id }
            public var remindersCount: Int
            public var remindersList: RemindersList
        }

        @Selection
        public struct Stats: Sendable, Equatable {
            var allCount = 0
            var flaggedCount = 0
            var scheduledCount = 0
            var todayCount = 0
            var completedCount = 0
        }

        var heatMapCellModels: [RemindersListHeatMapCell.Model] {
            [
                RemindersListHeatMapCell.Model(
                    colors: [0x2FB59B].map { Color(hex: $0) }, // teal (higher saturation)
                    count: stats.todayCount,
                    iconName: "sun.max.fill",
                    title: "Today",
                ),
                RemindersListHeatMapCell.Model(
                    colors: [0x5E79E6].map { Color(hex: $0) }, // vivid periwinkle
                    count: stats.scheduledCount,
                    iconName: "calendar.badge.clock",
                    title: "Scheduled",
                ),
                RemindersListHeatMapCell.Model(
                    colors: [0x2FB59B, 0x3DAE83, 0x6FBF5F, 0x5AA9C9, 0x5E79E6, 0xC56DA4, 0xE66D74].map { Color(hex: $0) }, // expanded, bridge-stop palette for gradient harmony
                    count: stats.allCount,
                    iconName: "square.grid.3x3.fill",
                    title: "All",
                ),
                RemindersListHeatMapCell.Model(
                    colors: [0xE66D74].map { Color(hex: $0) }, // soft red (more saturated)
                    count: stats.flaggedCount,
                    iconName: "flag.fill",
                    title: "Flagged",
                ),
                RemindersListHeatMapCell.Model(
                    colors: [0x6FBF5F].map { Color(hex: $0) }, // leaf green distinct from Today
                    count: stats.completedCount,
                    iconName: "checkmark.circle.fill",
                    title: "Completed",
                ),
            ]
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
            case onTapHeatMapCell(RemindersDetailReducer.DetailType)
        }
    }

    public var body: some ReducerOf<Self> {
        Reduce {
            state,
            action in
            switch action {
            case .destination:
                return .none
            case .view(.onTask):
                return .none
            case .view(.onTapRemindersList(let remindersListID)):
                guard
                    let remindersListState = state.remindersList.first(where: {
                        $0.id == remindersListID
                    })
                else {
                    return .none
                }
                state.destination = .remindersDetail(
                    RemindersDetailReducer.State(
                        detailType: .remindersList(
                            remindersListState.remindersList
                        )
                    )
                )
                return .none
            case .view(.onTapNewReminder):
                guard
                    let remindersList = state.remindersList.map(\.remindersList)
                        .first
                else {
                    reportIssue("There must be at least one list.")
                    return .none
                }
                state.destination = .reminderForm(
                    ReminderFormReducer.State(
                        reminder: Reminder.Draft(
                            remindersListID: remindersList.id
                        ),
                        remindersList: remindersList,
                    )
                )
                return .none
                
            case let .view(.onTapHeatMapCell(detailType)):
                state.destination = .remindersDetail(
                    RemindersDetailReducer.State(
                        detailType: detailType
                    )
                )
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension RemindersListHeatMapCell.Model: HeatMapValue {
    public var heat: Double {
        Double(count)
    }
}

@ViewAction(for: RemindersListReducer.self)
public struct RemindersListView: View {
    @Bindable public var store: StoreOf<RemindersListReducer>
    @State private var remindersListForm: RemindersList.Draft?
    public init(store: StoreOf<RemindersListReducer>) {
        self.store = store
    }
    public var body: some View {
        List {
            Section {
                remindersListHeatMap
                    .padding(.horizontal, -20)
            }
            
            Section {
                ForEach(store.remindersList) { remindersListState in
                    Button {
                        send(.onTapRemindersList(remindersListState.remindersList.id))
                    } label: {
                        HStack {
                            Image(systemName: "list.bullet.circle.fill")
                                .font(.largeTitle)
                                .foregroundStyle(remindersListState.remindersList.color)
                                .background(
                                    Color.white.clipShape(Circle()).padding(4)
                                )
                            Text(remindersListState.remindersList.title)
                            Spacer()
                            Text("\(remindersListState.remindersCount)")
                                .foregroundStyle(.gray)
                        }
                        .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                }
            } header: {
                Text("My Lists")
                  .font(.system(.title2, design: .rounded, weight: .bold))
                  .foregroundStyle(Color(.label))
                  .textCase(nil)
                  .padding(.top, -16)
            }
            .listRowInsets(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
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
        .navigationDestination(
            item: $store.scope(
                state: \.destination?.remindersDetail,
                action: \.destination.remindersDetail
            )
        ) { remindersDetailStore in
            RemindersDetailView(store: remindersDetailStore)
        }
    }

    private var remindersListHeatMap: some View {
        HeatMapView(
            items: store.heatMapCellModels,
            minAreaRatio: 0.1,
        ) { heatMapCellModel, _ in
            RemindersListHeatMapCell(
                model: heatMapCellModel
            ) { [title = heatMapCellModel.title] in
                let reminderDetailType: RemindersDetailReducer.DetailType = switch title {
                case "All": .all
                case "Today": .today
                case "Scheduled": .scheduled
                case "Flagged": .flagged
                case "Completed": .completed
                default: .all
                }
                send(.onTapHeatMapCell(reminderDetailType))
            }
        }
        .listRowBackground(Color.clear)
        .frame(height: 400)
    }
}

public struct RemindersListHeatMapCell: View {
    public struct Model: Identifiable {
        let colors: [Color]
        let count: Int
        let iconName: String
        let title: String

        public init(
            colors: [Color],
            count: Int,
            iconName: String,
            title: String
        ) {
            self.colors = colors
            self.count = count
            self.iconName = iconName
            self.title = title
        }

        public var id: String {
            title
        }
    }
    let model: Model
    let onTapHeatMapCell: () -> Void
    public init(
        model: Model,
        onTapHeatMapCell: @escaping () -> Void,
    ) {
        self.model = model
        self.onTapHeatMapCell = onTapHeatMapCell
    }

    public var body: some View {
        Button {
            onTapHeatMapCell()
        } label: {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: model.colors),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                HStack(alignment: .center, spacing: 12) {
                    // 图标：放入柔和容器里，弱化边缘对比
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.14))
                        Image(systemName: model.iconName)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.95))
                    }
                    .frame(width: 36, height: 36)

                    // 文案：左对齐，小标题 + 大数字，层级清晰
                    VStack(alignment: .leading, spacing: 2) {
                        Text(model.title)
                            .font(.subheadline)  // 不再全部使用粗体
                            .fontWeight(.semibold)
                            .foregroundStyle(.white.opacity(0.9))
                            .lineLimit(1)
                            .truncationMode(.tail)

                        Text("\(model.count)")
                            .font(.title3)  // 让数值成为视觉锚点
                            .monospacedDigit()
                            .fontWeight(.medium)
                            .foregroundStyle(.white)  // 相比标题稍更亮
                            .contentTransition(.numericText())
                    }
                }
            )
            .contentShape(Rectangle())
            .accessibilityElement(children: .combine)
        }
        .buttonStyle(.plain)
    }
}
