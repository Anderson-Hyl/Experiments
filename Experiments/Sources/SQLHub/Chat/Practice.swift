import Foundation
import SharingGRDB

enum Practice {
    
    // Q1.1 某房间最近 20 条未删除消息
    public func latestMessagesOf(space spaceID: Space.ID) -> some StructuredQueriesCore.Statement<Message> {
        Message
            .where { $0.spaceID.eq(spaceID) && $0.state.neq(MessageState.deleted) }
            .order { $0.createdAt.desc() }
            .limit(20)
            .select { $0 }
    }
    
    // Q1.2 某用户最近发表的 50 条消息（跨房间）
    public func latestMessagesOf(user userID: User.ID) -> some StructuredQueriesCore.Statement<Message> {
        Message
            .where { $0.authorID.eq(userID) && $0.state.neq(MessageState.deleted) }
            .order { $0.createdAt.desc() }
            .limit(50)
            .select { $0 }
    }
}
