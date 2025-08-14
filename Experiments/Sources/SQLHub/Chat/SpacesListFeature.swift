import SharingGRDB
import ComposableArchitecture
import SwiftUI

@Reducer
public struct SpacesListReducer {
    public init() {}
    
    @Reducer(state: .equatable)
    public enum Destination {
        case spaceDetail(MessageListReducer)
    }
    
    @ObservableState
    public struct State: Equatable {
        @FetchAll(
            Space
                .all
                .select { SpaceRow.Columns(space: $0) },
            animation: .default,
        )
        var spaceRowStates: [SpaceRow]
        var spaceRows: IdentifiedArrayOf<SpaceRowReducer.State> = []
        @Presents var destination: Destination.State?
        var selectedSpaceID: Space.ID?
        public init() {}
        
        @Selection
        struct SpaceRow: Equatable, Identifiable {
            var space: Space
            
            var id: UUID {
                space.id
            }
        }
    }
    
    public enum Action: ViewAction, BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case spaceRows(IdentifiedActionOf<SpaceRowReducer>)
        case spaceRowsUpdated([Space])
        case view(View)
        
        public enum View {
            case onTask
            case onTappedSpaceRow(Space.ID)
        }
    }
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce {
            state,
            action in
            switch action {
            case .binding:
                return .none
            case .destination:
                return .none
            case .spaceRows:
                return .none
            case .view(.onTask):
                state.spaceRows = IdentifiedArray(
                    uniqueElements: state.spaceRowStates.map { SpaceRowReducer.State(space: $0.space) }
                )
                return .publisher {
                    state.$spaceRowStates
                        .publisher
                        .map { Action.spaceRowsUpdated($0.map(\.space)) }
                }
                
            case let .spaceRowsUpdated(spaces):
                state.spaceRows = IdentifiedArray(
                    uniqueElements: spaces.map { SpaceRowReducer.State(space: $0) }
                )
                return .none
            case let .view(.onTappedSpaceRow(spaceID)):
                
                if state.selectedSpaceID == spaceID {
                    state.selectedSpaceID = nil
                } else {
                    state.selectedSpaceID = spaceID
                }
                return .none
            }
        }
        .forEach(\.spaceRows, action: \.spaceRows) {
            SpaceRowReducer()
        }
        .ifLet(\.$destination, action: \.destination)
    }
}


@ViewAction(for: SpacesListReducer.self)
public struct SpacesListView: View {
    @Bindable public var store: StoreOf<SpacesListReducer>
    public init(store: StoreOf<SpacesListReducer>) {
        self.store = store
    }
    public var body: some View {
        List {
            ForEach(
                store.scope(
                    state: \.spaceRows,
                    action: \.spaceRows
                )
            ) { spaceRowStore in
                SpaceRowView(store: spaceRowStore)
                    .onTapGesture {
                        send(.onTappedSpaceRow(spaceRowStore.id))
                    }
                    .listRowBackground(spaceRowBackground(of: spaceRowStore.id))
            }
        }
        .listStyle(.plain)
        .task {
            await send(.onTask).finish()
        }
        .navigationDestination(
            item: $store.scope(
                state: \.destination?.spaceDetail,
                action: \.destination.spaceDetail
            )
        ) { spaceDetailStore in
            MessageListView(store: spaceDetailStore)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    Image(systemName: "paperplane.circle.fill")
                        .foregroundStyle(Color.accentColor.gradient)
                        .fontWeight(.bold)
                    Text("Chats")
                        .font(.headline)
                        .fontWeight(.semibold)
                    ProgressView()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    private func spaceRowBackground(of spaceID: Space.ID) -> some View {
        if store.selectedSpaceID == spaceID {
            Color.accentColor.opacity(0.3)
        } else {
            EmptyView()
        }
    }
}
