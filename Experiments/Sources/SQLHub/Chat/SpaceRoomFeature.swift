import ComposableArchitecture
import Kingfisher
import SharingGRDB
import SwiftUI

@Reducer
public struct SpaceRoomReducer {
    public init() {}

    @ObservableState
    public struct State: Equatable {
        var messageList: MessageListReducer.State
        var messageInput = MessageInputReducer.State()

        var space: Space
        var user: User
        public init(space: Space, user: User) {
            self.space = space
            self.user = user
            self.messageList = MessageListReducer.State(spaceID: space.id)
        }
    }

    public enum Action: ViewAction {
        case messageList(MessageListReducer.Action)
        case messageInput(MessageInputReducer.Action)
        case view(View)

        public enum View {
            case onTask
        }
    }

    public var body: some ReducerOf<Self> {
        Scope(state: \.messageList, action: \.messageList) {
            MessageListReducer()
        }
        Scope(state: \.messageInput, action: \.messageInput) {
            MessageInputReducer()
        }
        Reduce { state, action in
            switch action {
            case .messageList:
                return .none
            case .messageInput:
                return .none
            case .view:
                return .none
            }
        }
    }
}

@ViewAction(for: SpaceRoomReducer.self)
public struct SpaceRoomView: View {
    public var store: StoreOf<SpaceRoomReducer>
    public init(store: StoreOf<SpaceRoomReducer>) {
        self.store = store
    }
    public var body: some View {
        VStack {
            MessageListView(
                store: store.scope(
                    state: \.messageList,
                    action: \.messageList
                )
            )
        }
        .safeAreaInset(edge: .bottom) {
            MessageInputView(
                store: store.scope(
                    state: \.messageInput,
                    action: \.messageInput
                )
            )
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(store.space.title ?? store.user.displayName)
                    .font(.headline)
                    .bold()
            }

            ToolbarItem(placement: .primaryAction) {
                Button {

                } label: {
                    SpaceAvatarView(
                        avatarSize: .medium,
                        space: store.space,
                        user: store.user
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}
