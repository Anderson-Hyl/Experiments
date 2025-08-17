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
                    "id" TEXT PRIMARY KEY NOT NULL,
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
                    "id" TEXT PRIMARY KEY NOT NULL,
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
                    "id" TEXT PRIMARY KEY NOT NULL,
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
                    "id" TEXT PRIMARY KEY NOT NULL,
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

		/// 批量生成 Chat 测试数据
		///
		/// - 参数说明:
		///   - userCount: 生成多少用户（会按 1/7 概率生成 bot）
		///   - directCount: 私聊会话个数（每个 2 人）
		///   - groupCount: 群聊会话个数（每个 3~8 人）
		///   - systemCount: 系统会话个数
		///   - daysBack: 消息分布在过去多少天
		///   - messagesPerSpaceRange: 每个会话生成的消息条数区间（闭区间）
		///   - threadProbability: 一条消息成为线程根的概率
		///   - replyFollowProbability: 线程根之后，下一条继续在同一线程里回复的概率
		func seedChatSampleData(
			userCount: Int = 60,
			directCount: Int = 40,
			groupCount: Int = 16,
			systemCount: Int = 2,
			daysBack: Int = 45,
			messagesPerSpaceRange: ClosedRange<Int> = 80...350,
			threadProbability: Double = 0.10,
			replyFollowProbability: Double = 0.50
		) throws {

			let now = Date()
			var rng = SystemRandomNumberGenerator()
			let me = UUID(0) // 本机登录用户

			// MARK: Helpers

			func randomDate(withinDaysBack days: Int) -> Date {
				let seconds = Double(Int.random(in: 0..<(days*24*3600), using: &rng))
				return now.addingTimeInterval(-seconds)
			}
			func randomTextToken() -> String {
				let bag = ["hello","world","swift","chat","tca","async","await","compose","actor","erlang","gleam","ocaml","lambda","query","index","sqlite","grdb","ios","watch","server","graph","hash","tool","call","media","event","bot","user","system","assistant","deadline","review","standup","sprint","design","perf","cache","retry","error","ok","done","note","todo","fix"]
				return bag.randomElement(using: &rng)!
			}
			func randomSentence(wordCount: Int) -> String {
				(0..<wordCount).map { _ in randomTextToken() }.joined(separator: " ")
			}
			func pickDistinctIndices(count: Int, from n: Int) -> [Int] {
				var idxs = Array(0..<n)
				idxs.shuffle(using: &rng)
				return Array(idxs.prefix(count))
			}

			// MARK: 1) Users 计划 & 插入

			let userIDs: [UUID] = (0..<userCount).map { i in i == 0 ? me : UUID() }

			try seed {
				for i in 0..<userCount {
					let created = randomDate(withinDaysBack: daysBack)
					User(
						id: userIDs[i],
						displayName: "User \(i)",
						avatarURL: Bool.random(using: &rng) ? nil : "https://picsum.photos/id/\(100 + i)/200/200",
						isBot: (i != 0) && (i % 7 == 0), // 避免把“我”标成 bot
						createdAt: created,
						updatedAt: now
					)
				}
			}

			// MARK: 2) Spaces 计划 & 插入

			let directSpaceIDs = (0..<directCount).map { _ in UUID() }
			let groupSpaceIDs  = (0..<groupCount).map { _ in UUID() }
			let systemSpaceIDs = (0..<systemCount).map { _ in UUID() }

			try seed {
				// Direct
				for sid in directSpaceIDs {
					let created = randomDate(withinDaysBack: daysBack)
					Space(id: sid, kind: .direct, title: nil,
								createdAt: created, updatedAt: created, archivedAt: nil, lastMessageAt: nil)
				}
				// Group
				for (i, sid) in groupSpaceIDs.enumerated() {
					let created = randomDate(withinDaysBack: daysBack)
					Space(id: sid, kind: .group, title: "Group \(i)",
								createdAt: created, updatedAt: created, archivedAt: nil, lastMessageAt: nil)
				}
				// System
				for (i, sid) in systemSpaceIDs.enumerated() {
					let created = randomDate(withinDaysBack: daysBack)
					Space(id: sid, kind: .system, title: "Announcements \(i)",
								createdAt: created, updatedAt: created, archivedAt: nil, lastMessageAt: nil)
				}
			}

			// MARK: 3) Participants 计划（先在 Swift 里计划，再插入）

			// 直聊：前 N 个强制包含“我”
			let directsWithMe = min(10, directCount)
			var directPairs: [(UUID, UUID)] = []
			for i in 0..<directCount {
				if i < directsWithMe {
					var other = userIDs.randomElement(using: &rng)!
					if other == me { other = userIDs[1] }
					directPairs.append((me, other))
				} else {
					let a = userIDs.randomElement(using: &rng)!
					var b = userIDs.randomElement(using: &rng)!
					if a == b { b = me }
					directPairs.append((a, b))
				}
			}

			// 群聊：至少一半包含“我”，成员 3~8 人
			var groupMembers: [UUID: [UUID]] = [:]
			for (i, sid) in groupSpaceIDs.enumerated() {
				var members = pickDistinctIndices(count: Int.random(in: 3...8, using: &rng), from: userCount).map { userIDs[$0] }
				if i % 2 == 0, !members.contains(me) { members[0] = me }
				members = Array(Set(members)) // 去重
				groupMembers[sid] = members
			}

			// 系统：全员
			var systemMembers: [UUID: [UUID]] = [:]
			for sid in systemSpaceIDs { systemMembers[sid] = userIDs }

			// 统一 participants 计划表
			var participantsBySpace: [UUID: [UUID]] = [:]
			for (i, sid) in directSpaceIDs.enumerated() { participantsBySpace[sid] = [directPairs[i].0, directPairs[i].1] }
			for (sid, m) in groupMembers { participantsBySpace[sid] = m }
			for (sid, m) in systemMembers { participantsBySpace[sid] = m }

			// 插入 participants
			try seed {
				// Direct
				for (i, sid) in directSpaceIDs.enumerated() {
					let (u1, u2) = directPairs[i]
					SpaceParticipant(id: UUID(), spaceID: sid, userID: u1, role: .member, isMuted: false, joinedAt: now, leftAt: nil)
					SpaceParticipant(id: UUID(), spaceID: sid, userID: u2, role: .member, isMuted: false, joinedAt: now, leftAt: nil)
				}
				// Group
				for sid in groupSpaceIDs {
					for (j, uid) in (groupMembers[sid] ?? []).enumerated() {
						let role: SpaceRole = j == 0 ? .owner : (j == 1 ? .admin : .member)
						SpaceParticipant(id: UUID(), spaceID: sid, userID: uid, role: role, isMuted: Bool.random(using: &rng), joinedAt: now, leftAt: nil)
					}
				}
				// System
				for sid in systemSpaceIDs {
					for uid in (systemMembers[sid] ?? []) {
						SpaceParticipant(id: UUID(), spaceID: sid, userID: uid, role: .member, isMuted: false, joinedAt: now, leftAt: nil)
					}
				}
			}

			// MARK: 4) Messages 计划 & 插入

			func roleForAuthor(_ uid: UUID) -> MessageRole {
				if let idx = userIDs.firstIndex(of: uid), idx != 0, idx % 7 == 0 {
					return Bool.random(using: &rng) ? .assistant : .system
				}
				return .user
			}
			func randomMessageType() -> MessageType {
				let r = Double.random(in: 0..<1, using: &rng)
				switch r {
				case ..<0.75: return .text
				case ..<0.88: return .media
				case ..<0.97: return .toolCall
				default:      return .event
				}
			}

			let allSpaces = directSpaceIDs + groupSpaceIDs + systemSpaceIDs

			for sid in allSpaces {
				guard let authors = participantsBySpace[sid], !authors.isEmpty else { continue }

				let n = Int.random(in: messagesPerSpaceRange, using: &rng)
				let ts = (0..<n).map { _ in randomDate(withinDaysBack: daysBack) }.sorted()

				var msgs: [Message] = []
				var currentThreadRoot: UUID? = nil
				var lastMessageID: UUID? = nil

				for (i, t) in ts.enumerated() {
					let seq = Int64(i + 1)
					let mid = UUID()
					let author = authors.randomElement(using: &rng)!
					let role = roleForAuthor(author)
					let type = randomMessageType()

					var replyTo: UUID? = nil
					var threadRoot: UUID? = nil
					if Bool.random(using: &rng, probability: threadProbability) {
						currentThreadRoot = mid
						threadRoot = mid
					} else if let root = currentThreadRoot,
										Bool.random(using: &rng, probability: replyFollowProbability) {
						threadRoot = root
						replyTo = lastMessageID ?? root
					} else if Bool.random(using: &rng) {
						currentThreadRoot = nil
					}

					let edited  = Bool.random(using: &rng, probability: 0.06) ? t.addingTimeInterval(60) : nil
					let deleted = Bool.random(using: &rng, probability: 0.03) ? t.addingTimeInterval(Double(Int.random(in: 120...7200, using: &rng))) : nil

					msgs.append(
						Message(
							id: mid, spaceID: sid, authorID: author,
							role: role, type: type, state: .sent,
							spaceSeq: seq,
							text: type == .text ? randomSentence(wordCount: Int.random(in: 3...16, using: &rng)) : "\(type)",
							contentJSON: nil,
							replyToMessageID: replyTo,
							threadRootID: threadRoot,
							createdAt: t, sentAt: t, editedAt: edited, deletedAt: deleted
						)
					)
					lastMessageID = mid
				}

				try seed {
					for m in msgs { m }
				}
			}

			// MARK: 5) 回填 lastMessageAt（未删除消息的最大 createdAt）
			try #sql(
				"""
				UPDATE spaces
				SET lastMessageAt = (
					SELECT MAX(createdAt)
					FROM messages
					WHERE messages.spaceID = spaces.id
						AND messages.deletedAt IS NULL
				),
						updatedAt = COALESCE(lastMessageAt, updatedAt)
				"""
			).execute(self)
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

private extension Bool {
	static func random<T: RandomNumberGenerator>(using rng: inout T, probability p: Double) -> Bool {
		precondition(p >= 0 && p <= 1, "probability must be 0...1")
		return Double.random(in: 0..<1, using: &rng) < p
	}
}
