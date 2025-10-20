import Foundation
import SharingGRDB

@Selection
struct ReminderRow: Identifiable, Equatable, Sendable {
    var id: Reminder.ID { reminder.id }
    let color: Int
    let reminder: Reminder
    let isPastDue: Bool
    let notes: String
    @Column(as: [String].JSONRepresentation.self)
    let tags: [String]
}
