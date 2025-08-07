import Foundation

public struct NotLocalized: ExpressibleByStringLiteral {
    private let value: String
    public init(stringLiteral value: String) {
        self.value = value
    }
    
    public var displayText: String {
        "\(value)"
    }
}

extension NotLocalized: CustomStringConvertible {
    public var description: String {
        displayText
    }
}

extension NotLocalized: ExpressibleByStringInterpolation {}

// NOTE: define unlocalized strings as extension to NotLocalized
// strong typing makes it easy to reuse strings in multiple contexts
public extension NotLocalized {
    static let empty: Self = ""
}
