import Base
import Foundation

public extension TimeInterval {
    var pieces: (hours: Int, minutes: Int, seconds: Int) {
        return (hours: Int(floor(self / 3600)), minutes: Int(floor((self / 60).truncatingRemainder(dividingBy: 60))), seconds: Int(self.truncatingRemainder(dividingBy: 60)))
    }
    
    func hours() -> Double {
        return self / 60.0 / 60.0
    }
    
    init(fromHours: Int) {
        self.init(fromHours * 60 * 60)
    }
    
    init(fromMinutes: Int) {
        self.init(fromMinutes * 60)
    }
}

public extension TimeInterval {
    // Values in seconds
    static let year = 31449600.0
    static let week = 604800.0
    static let day = 86400.0
    static let hour = 3600.0
    static let minute = 60.0
    
    func duration() -> String {
        if self >= TimeInterval.year {
            let years = Int(floor(self / TimeInterval.year))
            let weeks = Int(floor(self.truncatingRemainder(dividingBy: TimeInterval.year) / TimeInterval.week))
            if years < 5 && weeks > 0 {
                return String(format: "%dy %dw", years, weeks)
            } else {
                return String(format: "%dy", years)
            }
        } else if self >= TimeInterval.week {
            let weeks = Int(floor(self / TimeInterval.week))
            let days = Int(floor(self.truncatingRemainder(dividingBy: TimeInterval.week) / TimeInterval.day))
            if days > 0 {
                return String(format: "%dw %dd", weeks, days)
            } else {
                return String(format: "%dw", weeks)
            }
        } else if self >= TimeInterval.day {
            let days = Int(floor(self / TimeInterval.day))
            let hours = Int(floor(self.truncatingRemainder(dividingBy: TimeInterval.day) / TimeInterval.hour))
            if hours > 0 {
                return String(format: "%dd %dh", days, hours)
            } else {
                return String(format: "%dd", days)
            }
        } else if self >= TimeInterval.hour {
            let hours = Int(floor(self / TimeInterval.hour))
            let minutes = Int(floor(self.truncatingRemainder(dividingBy: TimeInterval.hour) / TimeInterval.minute))
            if minutes > 0 {
                return String(format: "%dh %dmin", hours, minutes)
            } else {
                return String(format: "%dh", hours)
            }
        } else {
            let minutes = Int(floor(self / TimeInterval.minute))
            return String(format: "%dmin", minutes)
        }
    }
}

extension TimeInterval {
    var centiseconds: Double {
        return self * 100
    }
    
    var minutes: Double {
        return self / 60.0
    }
}

extension TimeInterval {
    func milliseconds(_ rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> Int {
        let milliseconds = (self * 1000).rounded(rule)
        
        if milliseconds <= Double(Int.max) && milliseconds >= Double(Int.min) {
            return Int(milliseconds)
        } else {
            // If somehow we're still out of bounds, return max or min as a fallback
            return milliseconds > 0 ? Int.max : Int.min
        }
    }
    
    var millisecondsInt64: Int64 {
        return Int64(self) * 1000
    }
    
    var centisecondsInt32: Int32 {
        return Int32(rounding: centiseconds)
    }
}

extension TimeInterval {
    func roundedToMinutes(_ rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> Double {
        (self / 60.0).rounded(rule) * 60.0
    }
}
