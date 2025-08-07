import Base
import Foundation
public struct SemanticVersion: Codable, Comparable, CustomStringConvertible {
    public let major: Int
    public let minor: Int
    public let patch: Int
    
    public var version: String { return "\(major).\(minor).\(patch)" }
    
    // MARK: - CustomStringConvertible
    
    public var description: String { return version }
    
    // MARK: - Initializers
    
    public init(major: Int, minor: Int = 0, patch: Int = 0) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }
    
    public init?(from version: String) {
        let regex = try! NSRegularExpression(pattern: #"(\d+)\.(\d+)\.(\d+).*"#, options: [])
        if let match = regex.firstMatch(in: version, options: [], range: NSRange(location: 0, length: version.utf16.count)) {
            let results = (1...3).map { index -> Int in
                if let range = Range(match.range(at: index), in: version) {
                    return Int(version[range]) ?? 0
                }
                return 0
            }
            self.init(major: results[0], minor: results[1], patch: results[2])
            return
        }
        return nil
    }
    
    // MARK: - Comparable
    
    public static func <(lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
        return (lhs.major < rhs.major) ||
            (lhs.major == rhs.major && lhs.minor < rhs.minor) ||
            (lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.patch < rhs.patch)
    }
    
    public static func <=(lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
        return (lhs < rhs) || (lhs == rhs)
    }
    
    public static func >=(lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
        return !(lhs < rhs)
    }
    
    public static func >(lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
        return !(lhs <= rhs)
    }
    
    // MARK: - Equatable (via Comparable)
    
    public static func ==(lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
        return lhs.major == rhs.major &&
            lhs.minor == rhs.minor &&
            lhs.patch == rhs.patch
    }
}
