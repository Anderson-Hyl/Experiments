import Foundation
import OSLog

#if DEBUG

@available(watchOS 7.0, *)
public func traceLog(function: String = #function, fileID: String = #fileID, line: Int = #line) {
    enum Holder { static let logger: Logger = .init() }
    
    Holder.logger.traceLog(function: function, fileID: fileID, line: line)
}

#else

public func traceLog(function: String = #function, fileID: String = #fileID, line: Int = #line) {
    // No-op in release builds
}

#endif

@available(watchOS 7.0, *)
public extension Logger {
    func traceLog(function: String = #function, fileID: String = #fileID, line: Int = #line) {
        self.debug("Function: \(function), File: \(fileID), Line: \(line)")
    }
}

@available(watchOS 7.0, *)
public extension Logger {
    /// Creates a logger for the specified type.
    ///
    /// - Parameter type: The type for which to create the logger.
    /// - Returns: A configured Logger instance.
    static func forType<T>(_ type: T.Type) -> Logger {
        let subsystem = Bundle.main.bundleIdentifier ?? "unknown.bundle"
        let category = String(reflecting: type)
        return Logger(subsystem: subsystem, category: category)
    }
}
