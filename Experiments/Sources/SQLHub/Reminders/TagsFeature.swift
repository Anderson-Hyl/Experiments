import ComposableArchitecture
import SwiftUI
import SharingGRDB

@Reducer
public struct TagsReducer {
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        @FetchAll(Tag.all) var tags
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

@ViewAction(for: TagsReducer.self)
public struct TagsView: View {
    public let store: StoreOf<TagsReducer>
    public init(store: StoreOf<TagsReducer>) {
        self.store = store
    }
    public var body: some View {
        Form {
            Section {
                ForEach(store.tags) { tag in
                    HStack {
                        Image(systemName: "checkmark")
                        Text(tag.title)
                    }
                    .tint(.accentColor)
                }
            }
        }
        .task {
            await send(.onTask).finish()
        }
    }
}
