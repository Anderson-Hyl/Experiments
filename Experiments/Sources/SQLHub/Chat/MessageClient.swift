import Dependencies
import DependenciesMacros
import Foundation
import SharingGRDB

@DependencyClient
public struct MessageClient: Sendable {
    public var sendMessages: @Sendable ([Message]) async throws -> Void
    public var listenToMessages: @Sendable (User.ID) async throws -> Void
}

extension MessageClient: DependencyKey {
    public static let liveValue: Self = MessageClient(
        sendMessages: { _ in },
        listenToMessages: { _ in }
    )

    public static let randomGeneratorValue: Self = MessageClient(
        sendMessages: { messages in
            @Dependency(\.defaultDatabase) var database
            try await database.write { db in
                for message in messages {
                    try Message
                        .insert { message }
                        .execute(db)
                }
            }
        },
        listenToMessages: { authUserID in
            
            @Dependency(\.defaultDatabase) var database
            @Dependency(\.date.now) var now  // 可测试时间
            @Dependency(\.uuid) var uuid  // 可测试 UUID
            @Dependency(\.continuousClock) var clock

            let spaceIDs = try await database.read { db in
                try Space
                    .select(\.id)
                    .fetchAll(db)
            }

            
            while true {
                if Task.isCancelled { break }
                do {
                    
                    try await database.write { db in
                        // 1) 随机一个 Space
                        guard let spaceID = spaceIDs.randomElement() else {
                            return  // 没有空间，跳过这一轮
                        }

                        // 2) 读取该 Space 的最新一条作为“被回复对象”（或基准游标）
                        //    注意：在同一个 write 事务内读写，可以避免并发竞态
                        let latest: Message? =
                            try Message
                            .where { $0.spaceID.eq(spaceID) }
                            .order { $0.spaceSeq.desc() }  // 或 createdAt.desc()
                            .limit(1)
                            .select { $0 }
                            .fetchOne(db)

                        // 3) 计算下一个 spaceSeq（从 1 开始）
                        let nextSeq: Int64 = (latest?.spaceSeq ?? 0) &+ 1

                        // 4) 随机作者（被回复作者 vs 当前用户），为空则用当前用户兜底
                        let otherAuthor = latest?.authorID
                        let chosenAuthor: User.ID =
                            [otherAuthor, authUserID]
                            .compactMap { $0 }
                            .randomElement() ?? authUserID

                        // 5) 构造草稿
                        let text = randomSentence(
                            wordCount: Int.random(in: 4..<20)
                        )
                        let created = now
                        let draft = Message.Draft(
                            spaceID: spaceID,
                            authorID: chosenAuthor,
                            role: .user,
                            type: .text,
                            state: .delivered,
                            spaceSeq: nextSeq,
                            text: text,
                            replyToMessageID: latest?.id,  // 有则串起 thread
                            createdAt: created,
                            sentAt: created
                        )

                        // 6) 插入（仍在同一事务中，保证 seq 唯一）
                        try Message.insert { draft }.execute(db)
                    }

                    // 7) 随机停顿（可取消 & 可测试）
                    let seconds = Double(Int.random(in: 3..<20))
                    try await clock.sleep(for: .seconds(seconds))

                } catch is CancellationError {
                    break  // 取消睡眠时会抛出，正常退出
                } catch {
                    // 这里可以打印/记录错误，再稍作等待避免热循环
                    // print("listenToMessages error: \(error)")
                    try? await clock.sleep(for: .seconds(1))
                }
            }
        }
    )
}

private func randomTextToken() -> String {
    let bag = [
        "hello", "world", "swift", "chat", "tca", "async", "await", "compose",
        "actor", "erlang", "gleam", "ocaml", "lambda", "query", "index",
        "sqlite", "grdb", "ios", "watch", "server", "graph", "hash", "tool",
        "call", "media", "event", "bot", "user", "system", "assistant",
        "deadline", "review", "standup", "sprint", "design", "perf", "cache",
        "retry", "error", "ok", "done", "note", "todo", "fix",
    ]
    return bag.randomElement()!
}

private func randomSentence(
    wordCount: Int
) -> String {
    (0..<wordCount).map { _ in randomTextToken() }.joined(
        separator: " "
    )
}
