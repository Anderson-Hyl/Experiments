import ComposableArchitecture
import SharingGRDB
import SwiftUI

@Reducer
public struct MessageListReducer {
    public init() {}

    @ObservableState
    public struct State: Equatable {
        var spaceID: Space.ID
        var authUserID: User.ID
        @FetchAll var messages: [Message]
        public init(spaceID: Space.ID) {
            self.spaceID = spaceID
            self.authUserID = UUID(uuidString: "cfe8415d-919e-4be8-bfa1-7a6253c5690a")!
            self._messages = FetchAll(
                wrappedValue: [],
                messagesQuery,
            )
        }

        private var messagesQuery: some StructuredQueriesCore.Statement<Message>
        {
            Message
                .where { $0.spaceID.eq(spaceID) }
                .order { $0.createdAt.desc() }
                .select { $0 }
        }
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
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack {
                    ForEach(store.messages) { message in
                        messageContent(message: message)
                    }
                }
            }
            .flippedUpsideDown()
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
