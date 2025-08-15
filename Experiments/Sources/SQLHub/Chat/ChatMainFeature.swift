import SwiftUI
import ComposableArchitecture
import SharingGRDB

@Reducer
public struct ChatMainReducer {
    public init() {}
//    
//    @ObservableState
//    public struct State: Equatable {
//        
//    }
//    
//    public enum Action {
//        
//    }
//    
//    public var body: some ReducerOf<Self> {
//        Reduce { state, action in
//                .none
//        }
//    }
}

public struct ChatMainView: View {
    @Bindable var store: StoreOf<ChatMainReducer>
    public init(store: StoreOf<ChatMainReducer>) {
        self.store = store
    }
    public var body: some View {
        NavigationSplitView {
            
        } detail: {
            
        }

    }
}
