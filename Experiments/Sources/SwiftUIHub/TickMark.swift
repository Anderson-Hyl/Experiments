import Foundation

enum WatchDialConstants {
    static let degreesPerCircle: Double = 360
    static let minutesPerHour: Int = 60
}

enum TickMarkStyle {
    static let hour: (width: CGFloat, height: CGFloat, opacity: Double) = (2, 10, 1.0)
    static let fifteenMinute: (width: CGFloat, height: CGFloat, opacity: Double) = (1, 6, 0.7)
    static let fiveMinute: (width: CGFloat, height: CGFloat, opacity: Double) = (0.8, 4, 0.5)
    static let minute: (width: CGFloat, height: CGFloat, opacity: Double) = (0.5, 2, 0.3)
}

public struct TickMark: Identifiable, Sendable {
    public let index: Int
    public let angle: Double     // degrees
    public let type: TickType
    public var id: Int { index }
    public init(index: Int, angle: Double, type: TickType) {
        self.index = index
        self.angle = angle
        self.type = type
    }
}

public enum TickType: Sendable {
    case minute
    case fiveMinutes
    case fifteenMinutes
    case hour
    
    public var style: (width: CGFloat, height: CGFloat, opacity: Double) {
        switch self {
        case .hour: return TickMarkStyle.hour
        case .fifteenMinutes: return TickMarkStyle.fifteenMinute
        case .fiveMinutes: return TickMarkStyle.fiveMinute
        case .minute: return TickMarkStyle.minute
        }
    }
}

public struct TickMarkConfiguration: Sendable {
    public let hoursPerDial: Int      // 12 or 24
    public let intervalMinutes: Int   // e.g. 5 means one tick every 5 minutes
    public init(hoursPerDial: Int, intervalMinutes: Int) {
        self.hoursPerDial = hoursPerDial
        self.intervalMinutes = intervalMinutes
    }
    public static let standard: TickMarkConfiguration = .init(
        hoursPerDial: 24,
        intervalMinutes: 5
    )
}

extension TickMarkConfiguration {
    public func generateTicks() -> [TickMark] {
        let totalMinutes = hoursPerDial * 60
        let tickCount = totalMinutes / intervalMinutes
        let degreesPerTick = 360.0 / Double(tickCount)

        return (0..<tickCount).map { i in
            let minutes = i * intervalMinutes
            let type: TickType
            if minutes % 60 == 0 {
                type = .hour
            } else if minutes % 15 == 0 {
                type = .fifteenMinutes
            } else if minutes % 5 == 0 {
                type = .fiveMinutes
            } else {
                type = .minute
            }
            return TickMark(index: i, angle: degreesPerTick * Double(i), type: type)
        }
    }
}
