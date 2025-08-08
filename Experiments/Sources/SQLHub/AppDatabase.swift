import Foundation
import SharingGRDB
import OSLog
import SwiftUI

private let logger = Logger(subsystem: "SQLHub", category: "ApplicationDB")

public func applicationDB() throws -> any DatabaseWriter {
    let database: any DatabaseWriter
    @Dependency(\.context) var context
    var migrator = DatabaseMigrator()
    var configuration = Configuration()
    configuration.prepareDatabase { db in
        #if DEBUG
            db.trace(options: .profile) {
                if context == .live {
                    logger.debug("\($0.expandedDescription)")
                } else {
                    print("\($0.expandedDescription)")
                }
            }
        #endif
    }
    if context == .preview {
        database = try DatabaseQueue(configuration: configuration)
    } else {
        let path =
            context == .live
            ? URL.documentsDirectory.appending(component: "db.sqlite").path()
            : URL.temporaryDirectory.appending(
                component: "\(UUID().uuidString)-db.sqlite"
            ).path()
        logger.info("open \(path)")
        database = try DatabasePool(path: path, configuration: configuration)
    }
    migrator.registerMigration("Create 'facts' table") { db in
        try #sql(
            """
            CREATE TABLE "facts" (
              "id" INTEGER PRIMARY KEY,
              "body" TEXT NOT NULL,
              "count" INTEGER NOT NULL DEFAULT 1,
              "updatedAt" TEXT NOT NULL
            )
            """
        )
        .execute(db)
    }
    migrator.registerMigration("Create 'Reminders' tables") { db in
        let defaultListColor = Color.HexRepresentation(queryOutput: RemindersList.defaultColor).hexValue
        try #sql(
            """
            CREATE TABLE "remindersLists" (
                "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
                "color" INTEGER NOT NULL DEFAULT \(raw: defaultListColor ?? 0),
                "position" INTEGER NOT NULL DEFAULT 0,
                "title" TEXT NOT NULL
            ) STRICT
            """
        )
        .execute(db)
        
        try #sql(
            """
            CREATE TABLE "reminders" (
                "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
                "dueDate" TEXT,
                "isCompleted" INTEGER NOT NULL DEFAULT 0,
                "isFlagged" INTEGER NOT NULL DEFAULT 0,
                "notes" TEXT,
                "position" INTEGER NOT NULL DEFAULT 0,
                "priority" INTEGER,
                "remindersListID" TEXT NOT NULL,
                "title" TEXT NOT NULL,
            
                FOREIGN KEY("remindersListID") REFERENCES "remindersLists"("id") ON DELETE CASCADE
            ) STRICT
            """
        )
        .execute(db)
        
        try #sql(
            """
            CREATE TABLE "tags" (
                "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
                "title" TEXT NOT NULL COLLATE NOCASE
            ) STRICT
            """
        )
        .execute(db)
        
        try #sql(
            """
            CREATE TABLE "reminderTags" (
                "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
                "reminderID" TEXT NOT NULL,
                "tagID" TEXT NOT NULL,
            
                FOREIGN KEY("reminderID") REFERENCES "reminders"("id") ON DELETE CASCADE,
                FOREIGN KEY("tagID") REFERENCES "tags"("id") ON DELETE CASCADE
            ) STRICT
            """
        )
        .execute(db)
    }
    
    try migrator.migrate(database)
    return database
}


#if DEBUG
  extension Database {
    func seedSampleData() throws {
      let remindersListIDs = (0...2).map { _ in UUID() }
      let reminderIDs = (0...10).map { _ in UUID() }
      let tagIDs = (0...6).map { _ in UUID() }
      try seed {
        RemindersList(
          id: remindersListIDs[0],
          color: Color(red: 0x4a / 255, green: 0x99 / 255, blue: 0xef / 255),
          title: "Personal"
        )
        RemindersList(
          id: remindersListIDs[1],
          color: Color(red: 0xed / 255, green: 0x89 / 255, blue: 0x35 / 255),
          title: "Family"
        )
        RemindersList(
          id: remindersListIDs[2],
          color: Color(red: 0xb2 / 255, green: 0x5d / 255, blue: 0xd3 / 255),
          title: "Business"
        )
        Reminder(
          id: reminderIDs[0],
          notes: "Milk\nEggs\nApples\nOatmeal\nSpinach",
          remindersListID: remindersListIDs[0],
          title: "Groceries"
        )
        Reminder(
          id: reminderIDs[1],
          dueDate: Date().addingTimeInterval(-60 * 60 * 24 * 2),
          isFlagged: true,
          remindersListID: remindersListIDs[0],
          title: "Haircut"
        )
        Reminder(
          id: reminderIDs[2],
          dueDate: Date(),
          notes: "Ask about diet",
          priority: .high,
          remindersListID: remindersListIDs[0],
          title: "Doctor appointment"
        )
        Reminder(
          id: reminderIDs[3],
          dueDate: Date().addingTimeInterval(-60 * 60 * 24 * 190),
          isCompleted: true,
          remindersListID: remindersListIDs[0],
          title: "Take a walk"
        )
        Reminder(
          id: reminderIDs[4],
          dueDate: Date(),
          remindersListID: remindersListIDs[0],
          title: "Buy concert tickets"
        )
        Reminder(
          id: reminderIDs[5],
          dueDate: Date().addingTimeInterval(60 * 60 * 24 * 2),
          isFlagged: true,
          priority: .high,
          remindersListID: remindersListIDs[1],
          title: "Pick up kids from school"
        )
        Reminder(
          id: reminderIDs[6],
          dueDate: Date().addingTimeInterval(-60 * 60 * 24 * 2),
          isCompleted: true,
          priority: .low,
          remindersListID: remindersListIDs[1],
          title: "Get laundry"
        )
        Reminder(
          id: reminderIDs[7],
          dueDate: Date().addingTimeInterval(60 * 60 * 24 * 4),
          isCompleted: false,
          priority: .high,
          remindersListID: remindersListIDs[1],
          title: "Take out trash"
        )
        Reminder(
          id: reminderIDs[8],
          dueDate: Date().addingTimeInterval(60 * 60 * 24 * 2),
          notes: """
            Status of tax return
            Expenses for next year
            Changing payroll company
            """,
          remindersListID: remindersListIDs[2],
          title: "Call accountant"
        )
        Reminder(
          id: reminderIDs[9],
          dueDate: Date().addingTimeInterval(-60 * 60 * 24 * 2),
          isCompleted: true,
          priority: .medium,
          remindersListID: remindersListIDs[2],
          title: "Send weekly emails"
        )
        Reminder(
          id: reminderIDs[10],
          dueDate: Date().addingTimeInterval(60 * 60 * 24 * 2),
          isCompleted: false,
          remindersListID: remindersListIDs[2],
          title: "Prepare for WWDC"
        )
        Tag(id: tagIDs[0], title: "car")
        Tag(id: tagIDs[1], title: "kids")
        Tag(id: tagIDs[2], title: "someday")
        Tag(id: tagIDs[3], title: "optional")
        Tag(id: tagIDs[4], title: "social")
        Tag(id: tagIDs[5], title: "night")
        Tag(id: tagIDs[6], title: "adulting")
        ReminderTag.Draft(reminderID: reminderIDs[0], tagID: tagIDs[2])
        ReminderTag.Draft(reminderID: reminderIDs[0], tagID: tagIDs[3])
        ReminderTag.Draft(reminderID: reminderIDs[0], tagID: tagIDs[6])
        ReminderTag.Draft(reminderID: reminderIDs[1], tagID: tagIDs[2])
        ReminderTag.Draft(reminderID: reminderIDs[1], tagID: tagIDs[3])
        ReminderTag.Draft(reminderID: reminderIDs[2], tagID: tagIDs[6])
        ReminderTag.Draft(reminderID: reminderIDs[3], tagID: tagIDs[0])
        ReminderTag.Draft(reminderID: reminderIDs[3], tagID: tagIDs[1])
        ReminderTag.Draft(reminderID: reminderIDs[4], tagID: tagIDs[4])
        ReminderTag.Draft(reminderID: reminderIDs[3], tagID: tagIDs[4])
        ReminderTag.Draft(reminderID: reminderIDs[10], tagID: tagIDs[4])
        ReminderTag.Draft(reminderID: reminderIDs[4], tagID: tagIDs[5])
      }
    }
  }
#endif
