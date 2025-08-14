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
    migrator.registerReminderTables()
    migrator.registerChatTables()
    try migrator.migrate(database)
    return database
}

extension DatabaseMigrator {
    
    mutating func registerChatTables() {
        registerMigration("Create 'Chat' tables") { db in
            try #sql(
                """
                CREATE TABLE 'users' (
                    "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
                    "displayName" TEXT NOT NULL,
                    "avatarURL" TEXT,
                    "isBot" INTEGER NOT NULL DEFAULT 0,
                    "createdAt" TEXT NOT NULL,
                    "updatedAt" TEXT NOT NULL
                ) STRICT
                """
            )
            .execute(db)
            
            try #sql(
                """
                CREATE TABLE 'spaces' (
                    "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
                    "kind" INTEGER NOT NULL DEFAULT 0,
                    "title" TEXT,
                    "createdAt" TEXT NOT NULL,
                    "updatedAt" TEXT NOT NULL,
                    "archivedAt" TEXT,
                    "lastMessageAt" TEXT
                ) STRICT
                """
            )
            .execute(db)
            
            try #sql(
                """
                CREATE TABLE 'spaceParticipants' (
                    "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
                    "spaceID" TEXT NOT NULL,
                    "userID" TEXT NOT NULL,
                    "role" INTEGER NOT NULL DEFAULT 0,
                    "isMuted" INTEGER NOT NULL DEFAULT 0,
                    "joinedAt" TEXT NOT NULL,
                    "leftAt" TEXT,
                
                    FOREIGN KEY("spaceID") REFERENCES "spaces"("id") ON DELETE CASCADE,
                    FOREIGN KEY("userID") REFERENCES "users"("id") ON DELETE CASCADE
                ) STRICT
                """
            )
            .execute(db)
            
            try #sql(
                """
                CREATE TABLE 'messages' (
                    "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
                    "spaceID" TEXT NOT NULL,
                    "authorID" TEXT,
                    "role" INTEGER NOT NULL DEFAULT 0,
                    "type" INTEGER NOT NULL DEFAULT 0,
                    "state" INTEGER NOT NULL DEFAULT 0,
                    "text" TEXT,
                    "contentJSON" BLOB,
                    "replyToMessageID" TEXT,
                    "threadRootID" TEXT,
                    "createdAt" TEXT NOT NULL,
                    "sentAt" TEXT,
                    "editedAt" TEXT,
                    "deletedAt" TEXT,
                    "spaceSeq" INTEGER NOT NULL DEFAULT 0,
                
                    FOREIGN KEY("spaceID") REFERENCES "spaces"("id") ON DELETE CASCADE,
                    FOREIGN KEY("authorID") REFERENCES "users"("id") ON DELETE SET NULL,
                    FOREIGN KEY("replyToMessageID") REFERENCES "messages"("id") ON DELETE SET NULL,
                    FOREIGN KEY("threadRootID") REFERENCES "messages"("id") ON DELETE SET NULL
                ) STRICT
                """
            )
            .execute(db)
            
            #if DEBUG
            try db.seedChatSampleData()
            #endif
        }
    }
    
    mutating func registerReminderTables() {
        registerMigration("Create 'Reminders' tables") { db in
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
    }
}


#if DEBUG
  extension Database {
      func seedChatSampleData() throws {
        let now = Date()
        // Users
        let userIDs = [
          UUID(), // alice
          UUID(), // bob
          UUID(), // carol
          UUID(), // bot/system
        ]
        // Spaces
        let spaceIDs = [
          UUID(), // direct: alice ↔︎ bob
          UUID(), // group: team
          UUID(), // system: announcements
        ]

        try seed {
          // --- Users ---
          User(
            id: userIDs[0], displayName: "Alice", avatarURL: nil,
            isBot: false, createdAt: now, updatedAt: now
          )
          User(
            id: userIDs[1], displayName: "Bob", avatarURL: nil,
            isBot: false, createdAt: now, updatedAt: now
          )
          User(
            id: userIDs[2], displayName: "Carol", avatarURL: nil,
            isBot: false, createdAt: now, updatedAt: now
          )
          User(
            id: userIDs[3], displayName: "System Bot", avatarURL: nil,
            isBot: true, createdAt: now, updatedAt: now
          )

          // --- Spaces ---
          Space(
            id: spaceIDs[0], kind: .direct, title: nil,
            createdAt: now, updatedAt: now, archivedAt: nil, lastMessageAt: nil
          )
          Space(
            id: spaceIDs[1], kind: .group, title: "Team Chat",
            createdAt: now, updatedAt: now, archivedAt: nil, lastMessageAt: nil
          )
          Space(
            id: spaceIDs[2], kind: .system, title: "Announcements",
            createdAt: now, updatedAt: now, archivedAt: nil, lastMessageAt: nil
          )

          // --- Space Participants ---
          // direct: alice & bob
          SpaceParticipant(
            id: UUID(), spaceID: spaceIDs[0], userID: userIDs[0],
            role: .member, isMuted: false, joinedAt: now, leftAt: nil
          )
          SpaceParticipant(
            id: UUID(), spaceID: spaceIDs[0], userID: userIDs[1],
            role: .member, isMuted: false, joinedAt: now, leftAt: nil
          )

          // group: alice, bob, carol
          SpaceParticipant(
            id: UUID(), spaceID: spaceIDs[1], userID: userIDs[0],
            role: .owner, isMuted: false, joinedAt: now, leftAt: nil
          )
          SpaceParticipant(
            id: UUID(), spaceID: spaceIDs[1], userID: userIDs[1],
            role: .admin, isMuted: false, joinedAt: now, leftAt: nil
          )
          SpaceParticipant(
            id: UUID(), spaceID: spaceIDs[1], userID: userIDs[2],
            role: .member, isMuted: false, joinedAt: now, leftAt: nil
          )

          // system: 所有人 + bot（是否加成员关系看你的业务，这里示例加上）
          SpaceParticipant(
            id: UUID(), spaceID: spaceIDs[2], userID: userIDs[3],
            role: .admin, isMuted: false, joinedAt: now, leftAt: nil
          )
          SpaceParticipant(
            id: UUID(), spaceID: spaceIDs[2], userID: userIDs[0],
            role: .member, isMuted: true, joinedAt: now, leftAt: nil
          )
          SpaceParticipant(
            id: UUID(), spaceID: spaceIDs[2], userID: userIDs[1],
            role: .member, isMuted: false, joinedAt: now, leftAt: nil
          )
          SpaceParticipant(
            id: UUID(), spaceID: spaceIDs[2], userID: userIDs[2],
            role: .member, isMuted: false, joinedAt: now, leftAt: nil
          )

          // --- Messages (spaceSeq 单调递增 per space) ---

          // Direct (Alice ↔︎ Bob)
          let d0 = now.addingTimeInterval(-3600)
          let m00 = UUID(), m01 = UUID(), m02 = UUID()
          Message(
            id: m00,
            spaceID: spaceIDs[0],
            authorID: userIDs[0],
            role: .user, type: .text, state: .sent,
            spaceSeq: 1,
            text: "Hi Bob! Have you tried the new build?",
            contentJSON: nil, replyToMessageID: nil, threadRootID: nil,
            createdAt: d0, sentAt: d0, editedAt: nil, deletedAt: nil
          )
          Message(
            id: m01,
            spaceID: spaceIDs[0],
            authorID: userIDs[1],
            role: .user, type: .text, state: .sent,
            spaceSeq: 2,
            text: "Hey Alice, yes! It looks good so far 👍",
            contentJSON: nil, replyToMessageID: m00, threadRootID: nil,
            createdAt: d0.addingTimeInterval(60), sentAt: d0.addingTimeInterval(60),
            editedAt: nil, deletedAt: nil
          )
          Message(
            id: m02,
            spaceID: spaceIDs[0],
            authorID: userIDs[0],
            role: .user, type: .media, state: .sent,
            spaceSeq: 3,
            text: "Here is the screenshot.",
            contentJSON: nil, // 未来可放 JSON 块，例如附件元数据
            replyToMessageID: m01, threadRootID: nil,
            createdAt: d0.addingTimeInterval(120), sentAt: d0.addingTimeInterval(120),
            editedAt: nil, deletedAt: nil
          )

          // Group (Team Chat) with a thread
          let g0 = now.addingTimeInterval(-1800)
          let gm0 = UUID(), gm1 = UUID(), gm2 = UUID(), gm3 = UUID()
          // 根消息（线程根=自己）
          Message(
            id: gm0,
            spaceID: spaceIDs[1],
            authorID: userIDs[2],
            role: .user, type: .text, state: .sent,
            spaceSeq: 1,
            text: "Standup in 10 minutes. Any blockers?",
            contentJSON: nil,
            replyToMessageID: nil, threadRootID: gm0,
            createdAt: g0, sentAt: g0, editedAt: nil, deletedAt: nil
          )
          // 线程回复 1
          Message(
            id: gm1,
            spaceID: spaceIDs[1],
            authorID: userIDs[0],
            role: .user, type: .text, state: .sent,
            spaceSeq: 2,
            text: "All good here.",
            contentJSON: nil,
            replyToMessageID: gm0, threadRootID: gm0,
            createdAt: g0.addingTimeInterval(45), sentAt: g0.addingTimeInterval(45),
            editedAt: nil, deletedAt: nil
          )
          // 线程回复 2（assistant 示例）
          Message(
            id: gm2,
            spaceID: spaceIDs[1],
            authorID: userIDs[3], // bot
            role: .assistant, type: .text, state: .sent,
            spaceSeq: 3,
            text: "Reminder: sprint review tomorrow at 2pm.",
            contentJSON: nil,
            replyToMessageID: gm0, threadRootID: gm0,
            createdAt: g0.addingTimeInterval(60), sentAt: g0.addingTimeInterval(60),
            editedAt: nil, deletedAt: nil
          )
          // 非线程普通消息（toolCall 示例）
          Message(
            id: gm3,
            spaceID: spaceIDs[1],
            authorID: userIDs[1],
            role: .user, type: .toolCall, state: .sent,
            spaceSeq: 4,
            text: "run: summarize last standup", // 仅示意；未来可配合 ToolCall 表
            contentJSON: nil,
            replyToMessageID: nil, threadRootID: nil,
            createdAt: g0.addingTimeInterval(120), sentAt: g0.addingTimeInterval(120),
            editedAt: nil, deletedAt: nil
          )

          // System (Announcements)
          let s0 = now.addingTimeInterval(-600)
          let sm0 = UUID(), sm1 = UUID()
          Message(
            id: sm0,
            spaceID: spaceIDs[2],
            authorID: userIDs[3], // system bot
            role: .system, type: .event, state: .sent,
            spaceSeq: 1,
            text: "Welcome to Announcements channel.",
            contentJSON: nil,
            replyToMessageID: nil, threadRootID: nil,
            createdAt: s0, sentAt: s0, editedAt: nil, deletedAt: nil
          )
          Message(
            id: sm1,
            spaceID: spaceIDs[2],
            authorID: userIDs[3],
            role: .system, type: .text, state: .sent,
            spaceSeq: 2,
            text: "Downtime scheduled tonight 23:00–23:15 UTC.",
            contentJSON: nil,
            replyToMessageID: nil, threadRootID: nil,
            createdAt: s0.addingTimeInterval(90), sentAt: s0.addingTimeInterval(90),
            editedAt: nil, deletedAt: nil
          )
        }
      }
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
