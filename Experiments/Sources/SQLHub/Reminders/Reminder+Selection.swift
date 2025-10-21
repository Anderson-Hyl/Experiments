import Foundation
import SharingGRDB

@Selection
public struct ReminderRow: Identifiable, Equatable, Sendable {
    public var id: Reminder.ID { reminder.id }
    public let color: Int
    public let reminder: Reminder
    public let isPastDue: Bool
    public let notes: String
    @Column(as: [String].JSONRepresentation.self)
    public let tags: [String]
    
    public init(
        color: Int,
        reminder: Reminder,
        isPastDue: Bool,
        notes: String,
        tags: [String]
    ) {
        self.color = color
        self.reminder = reminder
        self.isPastDue = isPastDue
        self.notes = notes
        self.tags = tags
    }
}
