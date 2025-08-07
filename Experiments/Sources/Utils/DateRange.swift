import Base
import Foundation

public protocol DateRange {
    var from: Date { get }
    var to: Date { get }
    func contains(_ time: Date) -> Bool
}

extension DateRange {
    public func contains(_ time: Date) -> Bool {
        return self.from <= time && time < self.to
    }
}

public struct TimeRange: DateRange, Equatable {
    public let from: Date
    public let to: Date
    
    public var last: Date? {
        return Calendar.current.date(byAdding: .second, value: -1, to: to)
    }
    
    public init(from: Date, to: Date) {
        self.from = from
        self.to = to
    }
    
    public init(range: ClosedRange<Date>) {
        self.from = range.lowerBound
        self.to = range.upperBound
    }
    
    public func asClosedRange() -> ClosedRange<Date>? {
        guard from <= to else { return nil }
        
        return from...to
    }
    
    public func asRange() -> Range<Date>? {
        guard from <= to else { return nil }
        
        return from..<to
    }
}

extension TimeRange {
//    func splitTimeRange(for granularity: AnalysisGranularity) -> [TimeRange] {
//        var date = from
//        var array: [TimeRange] = []
//        while date <= to {
//            let dateTimeRange = granularity.timeRange(for: date)
//            array.append(dateTimeRange)
//            date = date.addDaysToDate(periods: 1)
//        }
//        return array
//    }
}

extension TimeRange {
    public func countofDays(_ calendar: Calendar = Calendar.current) -> Int {
        return calendar.dateComponents([.day], from: self.from, to: self.to).day ?? 0
    }
}

extension TimeRange: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.from)
        hasher.combine(self.to)
    }
}

public struct RangeOfDays: DateRange, Equatable {
    // 'startDate' and 'endDate' are the original timestamps of the period:
    public let startDate: Date
    public let endDate: Date
    // 'from' specifies the first moment of the day of the startTime:
    public var from: Date { startDate.beginningOfDay() }
    // 'to' specifies the first moment of the next day following the endTime:
    public var to: Date { endDate.startOfNextDay() }
    
    public init(start: Date, end: Date) {
        self.startDate = start
        self.endDate = end
    }
}

extension RangeOfDays {
    public static func last30Days(_ date: Date = Date()) -> RangeOfDays {
        return RangeOfDays(start: date.addDaysToDate(periods: -29), end: date)
    }
}
