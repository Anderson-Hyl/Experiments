import ComposableArchitecture
import SharingGRDB
import SwiftUI

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
    public init(store: StoreOf<RemindersDetailReducer>) {
        self.store = store
    }
    public var body: some View {
        EmptyView()
    }
}
