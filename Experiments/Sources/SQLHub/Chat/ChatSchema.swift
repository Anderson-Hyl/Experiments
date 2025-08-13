import Foundation
import SharingGRDB

@Table
public struct Dialog: Identifiable, Sendable, Equatable, Codable {
	public let id: UUID
	public var title: String
	
	public init(id: UUID, title: String) {
		self.id = id
		self.title = title
	}
}

extension Dialog.Draft: Identifiable {}

@Table
public struct Message: Identifiable, Sendable, Equatable, Codable {
	public let id: UUID
	public var dialogID: Dialog.ID
	public var messageType: MessageType
	public let messageState: MessageState
	public let messageRole: MessageRole
	public var sendAt: Date
	public var text: String
	
	public init(
		id: UUID,
		dialogID: UUID,
		messageType: MessageType,
		messageState: MessageState,
		messageRole: MessageRole,
		sendAt: Date = .now,
		text: String
	) {
		self.id = id
		self.dialogID = dialogID
		self.messageType = messageType
		self.messageState = messageState
		self.messageRole = messageRole
		self.sendAt = sendAt
		self.text = text
	}
}

public enum MessageType: Int, Codable, QueryBindable {
	case text = 0
}

extension Message.Draft: Equatable {}

public enum MessageRole: Int, Codable, QueryBindable, Hashable {
    case user = 0
    case assistant
    case system
}

public enum MessageState: Int, Codable, QueryBindable {
    case idle = 0
    case thinking
    case streaming
    case failed
    case success
    case cancelled
}
