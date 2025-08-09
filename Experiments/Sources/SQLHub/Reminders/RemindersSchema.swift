import Foundation
import SharingGRDB
import SwiftUI

@Table
public struct RemindersList: Identifiable, Equatable, Hashable, Sendable {
    public let id: UUID
    @Column(as: Color.HexRepresentation.self)
    public var color: Color = Self.defaultColor
    public var position = 0
    public var title = ""
    
    public static var defaultColor: Color { Color(red: 0x4a / 255, green: 0x99 / 255, blue: 0xef / 255) }
    public static var defaultTitle: String { "Personal" }
}

extension RemindersList.Draft: Identifiable, Equatable, Hashable, Sendable {}

@Table
public struct Reminder: Identifiable, Equatable, Sendable {
    public let id: UUID
    public var dueDate: Date?
    public var isCompleted = false
    public var isFlagged = false
    public var notes = ""
    public var position = 0
    public var priority: Priority?
    public var remindersListID: RemindersList.ID
    public var title = ""
    
    public init(
        id: UUID,
        dueDate: Date? = nil,
        isCompleted: Bool = false,
        isFlagged: Bool = false,
        notes: String = "",
        position: Int = 0,
        priority: Priority? = nil,
        remindersListID: RemindersList.ID,
        title: String = ""
    ) {
        self.id = id
        self.dueDate = dueDate
        self.isCompleted = isCompleted
        self.isFlagged = isFlagged
        self.notes = notes
        self.position = position
        self.priority = priority
        self.remindersListID = remindersListID
        self.title = title
    }
}

extension Reminder.TableColumns {
    var isScheduled: some QueryExpression<Bool> {
        !isCompleted && dueDate.isNot(nil)
    }
    var isToday: some QueryExpression<Bool> {
        @Dependency(\.date.now) var now
        return !isCompleted && #sql("coalesce(date(\(dueDate)) = date(\(now)), 0)")
    }
}

extension Reminder.Draft: Identifiable, Hashable, Sendable {}

public enum Priority: Int, QueryBindable {
    case low = 1
    case medium
    case high
}

@Table
public struct Tag: Identifiable, Equatable, Hashable, Sendable {
    public let id: UUID
    public var title = ""
    
    public init(
        id: UUID,
        title: String = ""
    ) {
        self.id = id
        self.title = title
    }
}


@Table
public struct ReminderTag: Identifiable, Sendable {
    public let id: UUID
    public var reminderID: Reminder.ID
    public var tagID: Tag.ID
    
    public init(
        id: UUID,
        reminderID: Reminder.ID,
        tagID: Tag.ID
    ) {
        self.id = id
        self.reminderID = reminderID
        self.tagID = tagID
    }
}
