import Foundation
import SharingGRDB
import OSLog

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
    try migrator.migrate(database)
    return database
}
