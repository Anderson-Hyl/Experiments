import SwiftUI
import ComposableArchitecture
import SharingGRDB
import Utils

@Reducer
public struct ChatMainReducer {
    public init() {}
    
    @Reducer(state: .equatable)
    public enum Destination {
        case spaceRoom(SpaceRoomReducer)
    }
    
    @ObservableState
    public struct State: Equatable {
        var spacesList: SpacesListReducer.State
        @Presents var destination: Destination.State?
        var spaceRoom: SpaceRoomReducer.State?
        @Shared var selectedSpaceID: Space.ID?
        public init() {
            let sharedSelected: Shared<Space.ID?> = .init(.uuidAppStorage("selectedSpaceID"))
          self._selectedSpaceID = sharedSelected
          self.spacesList = SpacesListReducer.State(selectedSpaceID: sharedSelected)
            self.spacesList = SpacesListReducer.State(
                selectedSpaceID: sharedSelected
            )
        }
    }
    
    public enum Action: ViewAction, BindableAction {
        case binding(BindingAction<State>)
        case didSelectSpace(Space.ID?)
        case didOpenSpaceRoom(Space, User)
        case spacesList(SpacesListReducer.Action)
        case spaceRoom(SpaceRoomReducer.Action)
        case view(View)
        
        public enum View {
            case onTask
        }
    }
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Scope(state: \.spacesList, action: \.spacesList) {
            SpacesListReducer()
        }
        Reduce {
            state,
            action in
            switch action {
            case .view(.onTask):
                return .publisher {
                    state.$selectedSpaceID
                        .publisher
                        .removeDuplicates(by: { $0 == $1 })
                        .map(Action.didSelectSpace)
                }
            case let .didSelectSpace(spaceID):
                return updateSelectedSpaceID(state: &state, spaceID: spaceID)
            case let .didOpenSpaceRoom(space, user):
                state.spaceRoom = SpaceRoomReducer.State(
                    space: space,
                    user: user
                )
                return .none
            case .binding:
                return .none
            case .spacesList:
                return .none
            case .spaceRoom:
                return .none
            case .view:
                return .none
            }
        }
        .ifLet(\.spaceRoom, action: \.spaceRoom) {
            SpaceRoomReducer()
        }
        ._printChanges()
    }
    
    private func updateSelectedSpaceID(state: inout State, spaceID: Space.ID?) -> Effect<Action> {
        guard let spaceID else {
            state.spaceRoom = nil
            return .none
        }
        return .run { [spaceID] send in
            @Dependency(\.defaultDatabase) var database
            let (space, user) = try await database.read { db -> (Space, User) in
                let space = try Space
                    .find(spaceID)
                    .fetchOne(db)!
                
                let user = try SpaceParticipant
                    .where { $0.spaceID.eq(spaceID) && $0.userID.neq(UUID(0)) }
                    .join(User.all) { $0.userID.eq($1.id) }
                    .limit(1)
                    .select { $1 }
                    .fetchOne(db)!
                return (space, user)
            }
            await send(.didOpenSpaceRoom(space, user))
        }
    }
}

@ViewAction(for: ChatMainReducer.self)
public struct ChatMainView: View {
    @Bindable public var store: StoreOf<ChatMainReducer>
    
    public init(store: StoreOf<ChatMainReducer>) {
        self.store = store
    }
    public var body: some View {
        NavigationSplitView {
            SpacesListView(
                store: store.scope(
                    state: \.spacesList,
                    action: \.spacesList
                )
            )
        } detail: {
            if let spaceRoomStore = store.scope(
                state: \.spaceRoom,
                action: \.spaceRoom
            ) {
                SpaceRoomView(store: spaceRoomStore)
            } else {
                ContentUnavailableView(
                    "Welcome to SQL-Chat",
                    systemImage: "bubble.left.and.text.bubble.right.fill"
                )
            }
        }
        .navigationSplitViewColumnWidth(min: 280, ideal: 320, max: 380)
        .task {
            await send(.onTask).finish()
        }
    }
}
