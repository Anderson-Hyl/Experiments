import Foundation

// MARK: - Property Wrappers

public protocol DateValueCodableStrategy {
    associatedtype RawValue: Codable
    
    static func decode(_ value: RawValue) throws -> Date
    static func encode(_ date: Date) -> RawValue
}

/// Uses a format to decode a date from Codable.
@propertyWrapper
public struct DateFormatted<T: DateValueCodableStrategy>: Codable {
    private let value: T.RawValue
    public var wrappedValue: Date
    
    public init(wrappedValue: Date) {
        self.wrappedValue = wrappedValue
        self.value = T.encode(wrappedValue)
    }
    
    public init(from decoder: Decoder) throws {
        self.value = try T.RawValue(from: decoder)
        self.wrappedValue = try T.decode(value)
    }
    
    public func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }
}

/// Uses a format to decode a date from Codable.
@propertyWrapper
public struct DateOptionalFormatted<T: DateValueCodableStrategy>: Codable {
    private let value: T.RawValue?
    public var wrappedValue: Date?
    
    public init(wrappedValue: Date?) {
        self.wrappedValue = wrappedValue
        self.value = wrappedValue.map { T.encode($0) }
    }
    
    public init(from decoder: Decoder) throws {
        self.value = try? T.RawValue(from: decoder)
        self.wrappedValue = value.flatMap { try? T.decode($0) }
    }
    
    public func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }
}

extension KeyedDecodingContainer {
    func decode<T>(_ type: DateOptionalFormatted<T>.Type, forKey key: K) throws -> DateOptionalFormatted<T> {
        // Make sure the key is optional
        if let value = try? decodeIfPresent(type, forKey: key) {
            return value
        } else {
            return DateOptionalFormatted<T>.init(wrappedValue: nil)
        }
    }
}

extension KeyedEncodingContainer {
    mutating func encode<T>(_ value: DateOptionalFormatted<T>, forKey key: KeyedEncodingContainer<K>.Key) throws {
        // exclude `"key": null`
        guard let _ = value.wrappedValue else { return }
        try self.encodeIfPresent(value, forKey: key)
    }
}

// MARK: - Date Formats

public struct DayDateStrategy: DateValueCodableStrategy {
    private static var formatter: Foundation.DateFormatter = {
        let formatter = Foundation.DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale.current
        return formatter
    }()
    
    private static let localDateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = .withFullDate
        return formatter
    }()
    
    public static func decode(_ value: String) throws -> Date {
        formatter.date(from: value) ?? Date()
    }
    
    public static func encode(_ date: Date) -> String {
        formatter.string(from: date)
    }
}

public struct LocalDateStrategy: DateValueCodableStrategy {
    private static let localDateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = .withFullDate
        return formatter
    }()
    
    public static func decode(_ value: String) throws -> Date {
        localDateFormatter.date(from: value) ?? Date()
    }
    
    public static func encode(_ date: Date) -> String {
        localDateFormatter.string(from: date)
    }
}
