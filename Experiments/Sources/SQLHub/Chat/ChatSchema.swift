import Foundation
import SharingGRDB

@Table
public struct User: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var displayName: String
    public var avatarURL: String?
    public var isBot: Bool
    public var createdAt: Date
    public var updatedAt: Date
	
	public init(
		id: UUID,
		displayName: String,
		avatarURL: String? = nil,
		isBot: Bool,
		createdAt: Date,
		updatedAt: Date
	) {
		self.id = id
		self.displayName = displayName
		self.avatarURL = avatarURL
		self.isBot = isBot
		self.createdAt = createdAt
		self.updatedAt = updatedAt
	}
	
	static let placeholder = User(id: UUID(), displayName: "", isBot: false, createdAt: Date(), updatedAt: Date())
}

public enum SpaceKind: Int, Codable, QueryBindable, Sendable {  // 会话类型
    case direct = 0  // 单聊/多方DM
    case group  // 群聊
    case system  // 系统/频道
}

@Table
public struct Space: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var kind: SpaceKind
    public var title: String?  // 群名 / 频道名；DM 可为空
    public var createdAt: Date
    public var updatedAt: Date
    public var archivedAt: Date?
    // 为排序准备：每条消息写入时更新
    public var lastMessageAt: Date?
}

// 参与者（多对多：User <-> Space）
public enum SpaceRole: Int, Codable, QueryBindable, Sendable {
    case member = 0
    case admin, owner
}

@Table
public struct SpaceParticipant: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var spaceID: Space.ID
    public var userID: User.ID
    public var role: SpaceRole
    public var isMuted: Bool
    public var joinedAt: Date
    public var leftAt: Date?
}

// MARK: - 消息流

public enum MessageRole: Int, Codable, QueryBindable, Hashable, Sendable {
    case user = 0
    case assistant, system, tool  // tool=函数/工具消息
}

public enum MessageType: Int, Codable, QueryBindable, Sendable {
    case text = 0
    case media  // 图片/音视频等，有附件表
    case event  // 入群/退群/重命名等系统事件
    case toolCall  // 触发函数调用（请求/结果细化到子表）
}

public enum MessageState: Int, Codable, QueryBindable, Sendable {
    case queued = 0  // 待发送/排队
    case sending
    case sent  // 已写入本地 & 服务器确认
    case delivered  // 对端/服务器已投递（可选）
    case read  // 本人已读（或对端已读，见 receipts 表）
    case failed
    case deleted  // 软删除
}

// **按会话单调递增的序号**，便于稳定排序与去重（离线同步强烈建议）
public typealias SeqNo = Int64

@Table
public struct Message: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var spaceID: Space.ID
    public var authorID: User.ID?
    public var role: MessageRole
    public var type: MessageType
    public var state: MessageState

    // 排序/并发冲突解决：同一 space 内单调递增
    public var spaceSeq: SeqNo

    // 业务字段
    public var text: String?  // 纯文本/markdown
    public var contentJSON: Data?  // 富内容（块、结构化片段，JSON 编码）
    public var replyToMessageID: Message.ID?  // 引用/回复
    public var threadRootID: Message.ID?  // 线程根（子线程场景）
    public var createdAt: Date  // 本地创建时间
    public var sentAt: Date?  // 服务器确认时间
    public var editedAt: Date?
    public var deletedAt: Date?
}

extension Message.Draft: Sendable {}

//@Table
//public struct Dialog: Identifiable, Sendable, Equatable, Codable {
//	public let id: UUID
//	public var title: String
//
//	public init(id: UUID, title: String) {
//		self.id = id
//		self.title = title
//	}
//}
//
//extension Dialog.Draft: Identifiable {}
//
//@Table
//public struct Message: Identifiable, Sendable, Equatable, Codable {
//	public let id: UUID
//	public var dialogID: Dialog.ID
//	public var messageType: MessageType
//	public let messageState: MessageState
//	public let messageRole: MessageRole
//	public var sendAt: Date
//	public var text: String
//
//	public init(
//		id: UUID,
//		dialogID: UUID,
//		messageType: MessageType,
//		messageState: MessageState,
//		messageRole: MessageRole,
//		sendAt: Date = .now,
//		text: String
//	) {
//		self.id = id
//		self.dialogID = dialogID
//		self.messageType = messageType
//		self.messageState = messageState
//		self.messageRole = messageRole
//		self.sendAt = sendAt
//		self.text = text
//	}
//}
//
//public enum MessageType: Int, Codable, QueryBindable {
//	case text = 0
//}
//
//extension Message.Draft: Equatable {}
//
//public enum MessageRole: Int, Codable, QueryBindable, Hashable {
//    case user = 0
//    case assistant
//    case system
//}
//
//public enum MessageState: Int, Codable, QueryBindable {
//    case idle = 0
//    case thinking
//    case streaming
//    case failed
//    case success
//    case cancelled
//}
