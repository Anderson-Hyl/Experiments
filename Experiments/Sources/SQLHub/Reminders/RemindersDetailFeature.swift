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
    
    @ObservableState
    public struct State: Equatable {
        let detailType: DetailType
        public init(detailType: DetailType) {
            self.detailType = detailType
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
            case .view:
                return .none
            }
        }
    }
}

@ViewAction(for: RemindersDetailReducer.self)
public struct RemindersDetailView: View {
    public var store: StoreOf<RemindersDetailReducer>
    @Environment(\.dismiss) var dismiss
    public init(store: StoreOf<RemindersDetailReducer>) {
        self.store = store
    }
    public var body: some View {
        VStack {
            
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
