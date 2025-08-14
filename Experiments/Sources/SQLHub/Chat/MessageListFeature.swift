import SwiftUI
import ComposableArchitecture


@Reducer
public struct MessageListReducer {
    public init() {}
    
    
    @ObservableState
    public struct State: Equatable {
        public init() {}
        
    }
    
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

@ViewAction(for: MessageListReducer.self)
public struct MessageListView: View {
    public var store: StoreOf<MessageListReducer>
    public init(store: StoreOf<MessageListReducer>) {
        self.store = store
    }
    public var body: some View {
        List {
            
        }
    }
}
