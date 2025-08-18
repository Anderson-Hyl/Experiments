import ComposableArchitecture
import SharingGRDB
import SwiftUI

private let messageListPageCount = 2

@Reducer
public struct MessageListReducer {
    public init() {}

    @ObservableState
    public struct State: Equatable {
        var spaceID: Space.ID
        var authUserID: User.ID
        var messages: [Message] = []
        var tailSeq: Int64 = .max
        var hasMoreMessages = true
        var isLoadingNextPage = false
        var anchorID: Message.ID?
        public init(spaceID: Space.ID) {
            self.spaceID = spaceID
            self.authUserID = UUID(0)
        }

        fileprivate var messagesQuery: some StructuredQueriesCore.Statement<Message>
        {
            Message
                .where { $0.spaceID.eq(spaceID) && $0.spaceSeq.lt(tailSeq) }
                .order { $0.spaceSeq.desc() }
                .limit(messageListPageCount)
                .select { $0 }
            
        }
    }

    public enum Action: ViewAction {
        case stopLoadingNextPage([Message])
        case view(View)

        public enum View {
            case onTask
            case loadNextPage
        }
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(.onTask), .view(.loadNextPage):
                return loadMessages(state: &state)
            case let .stopLoadingNextPage(messages):
                state.messages.append(contentsOf: messages)
                state.isLoadingNextPage = false
                state.hasMoreMessages = messages.count >= messageListPageCount
                if let lastMessage = messages.last {
                    state.tailSeq = lastMessage.spaceSeq
                }
                return .none
            }
        }
        ._printChanges()
    }
    
    private func loadMessages(state: inout State) -> Effect<Action> {
        guard state.hasMoreMessages, !state.isLoadingNextPage else {
            return .none
        }
        state.isLoadingNextPage = true
        return .run { [spaceID = state.spaceID, tailSeq = state.tailSeq] send in
            @Dependency(\.defaultDatabase) var database
            let messages = try await database.read { db in
                try Message
                    .where { $0.spaceID.eq(spaceID) && $0.spaceSeq.lt(tailSeq) }
                    .order { $0.spaceSeq.desc() }
                    .limit(messageListPageCount)
                    .fetchAll(db)
            }
            @Dependency(\.continuousClock) var clock
            try await clock.sleep(for: .seconds(1.5))
            await send(.stopLoadingNextPage(messages))
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
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack {
                    ForEach(store.messages) { message in
                        messageContent(message: message)
                    }
                }
                if store.isLoadingNextPage {
                    ProgressView()
                        .padding(.vertical)
                }
            }
            .flippedUpsideDown()
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                geometry.contentOffset.y
            } action: { oldValue, newValue in
                guard newValue >= 60 else { return }
                guard !store.isLoadingNextPage, store.hasMoreMessages else { return }
                send(.loadNextPage)
            }
            .task {
                await send(.onTask).finish()
            }
        }
    }

    private func adjacentMessages(for message: Message) -> (Message?, Message?)
    {
        guard
            let messageIndex = store.messages.firstIndex(where: {
                $0.id == message.id
            })
        else {
            return (nil, nil)
        }
        let previous =
            (messageIndex > 0) ? store.messages[messageIndex - 1] : nil
        let next =
            (messageIndex < store.messages.count - 1)
            ? store.messages[messageIndex + 1] : nil
        return (previous, next)
    }

    private func computeBubbleCorners(
        message: Message,
        previous: Message?,
        next: Message?
    ) -> (
        topLeft: CGFloat, topRight: CGFloat, bottomLeft: CGFloat,
        bottomRight: CGFloat
    ) {
        let isNextUserSame =
            next != nil && message.authorID == next!.authorID
        let isPreviousUserSame =
        previous != nil && (message.authorID) == (previous!.authorID)
        let isMine = message.authorID == store.authUserID
        var hasTimeDifferenceWithNext = false
        if let next {
            hasTimeDifferenceWithNext = next.createdAt.checkTimeDifference(
                message.createdAt
            )
        }
        var hasTimeDifferenceWithPrevious = false
        if let previous {
            hasTimeDifferenceWithPrevious = previous.createdAt
                .checkTimeDifference(message.createdAt)
        }
        let corner: CGFloat = 22
        let smallCorner: CGFloat = 4

        let topLeft: CGFloat =
            isMine
            ? corner
            : (isNextUserSame && !hasTimeDifferenceWithNext
                ? smallCorner : corner)
        let topRight: CGFloat =
            isMine
            ? (isNextUserSame && !hasTimeDifferenceWithNext
                ? smallCorner : corner)
            : corner
        let bottomLeft: CGFloat =
            isMine
            ? corner
            : (isPreviousUserSame && !hasTimeDifferenceWithPrevious
                ? smallCorner : 0)
        let bottomRight: CGFloat =
            isMine
            ? (isPreviousUserSame && !hasTimeDifferenceWithPrevious
                ? smallCorner : 0)
            : corner
        return (topLeft, topRight, bottomLeft, bottomRight)
    }
    
    private func messageContent(message: Message) -> some View {
        let (prev, next) = adjacentMessages(for: message)
        let corners = computeBubbleCorners(message: message, previous: prev, next: next)
        return MessageBubble(
            isMine: message.authorID == store.authUserID,
            message: message,
            corner: RectangleCornerRadii(
                topLeading: corners.topLeft,
                bottomLeading: corners.bottomLeft,
                bottomTrailing: corners.bottomRight,
                topTrailing: corners.topRight
            )
        )
        .id(message.id)
        .flippedUpsideDown()
        .padding(.horizontal, 6)
        .padding(.vertical, -3)
    }
}
