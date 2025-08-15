import Foundation

extension Date {
    public var age: Int {
        return (Calendar.current as NSCalendar)
            .components(
                NSCalendar.Unit.year,
                from: self,
                to: Date(),
                options: []
            ).year!
    }

    public static func date(
        year: Int,
        month: Int,
        day: Int,
        hour: Int? = nil,
        minute: Int? = nil,
        second: Int? = nil
    ) -> Date? {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        if hour != nil { components.hour = hour }
        if minute != nil { components.minute = minute }
        if second != nil { components.second = second }
        return Calendar.current.date(from: components)
    }

    public func computeTimeAgoSince(
        _ date: Date,
        numericDates: Bool,
        formats: [String: String],
        secondsInUse: Bool = true
    ) -> String {
        let calendar = Calendar.current
        let earliest = (date as NSDate).earlierDate(self)
        let latest = (earliest == date) ? self : date

        let dateComponents: DateComponents = (calendar as NSCalendar)
            .components(
                [
                    NSCalendar.Unit.day, NSCalendar.Unit.weekOfYear,
                    NSCalendar.Unit.month, NSCalendar.Unit.year,
                ],
                from: calendar.startOfDay(for: earliest),
                to: calendar.startOfDay(for: latest),
                options: NSCalendar.Options()
            )

        let timeComponents: DateComponents = (calendar as NSCalendar)
            .components(
                [
                    NSCalendar.Unit.second, NSCalendar.Unit.minute,
                    NSCalendar.Unit.hour,
                ],
                from: earliest,
                to: latest,
                options: NSCalendar.Options()
            )

        func format(
            _ amount: Int,
            _ numericDates: Bool,
            _ plural: String,
            _ numericOne: String,
            _ textualOne: String
        ) -> String {
            if amount == 1 {
                if numericDates {
                    return String(format: formats[numericOne]!, amount)
                } else {
                    return formats[textualOne]!
                }
            } else {
                return String(format: formats[plural]!, amount)
            }
        }

        if dateComponents.year! > 0 {
            return format(
                dateComponents.year!,
                numericDates,
                "years.ago",
                "year.ago",
                "last.year"
            )
        } else if dateComponents.month! > 0 {
            return format(
                dateComponents.month!,
                numericDates,
                "months.ago",
                "month.ago",
                "last.month"
            )
        } else if dateComponents.weekOfYear! > 0 {
            return format(
                dateComponents.weekOfYear!,
                numericDates,
                "weeks.ago",
                "week.ago",
                "last.week"
            )
        } else if dateComponents.day! > 0 && timeComponents.hour! >= 24 {
            return format(
                dateComponents.day!,
                numericDates,
                "days.ago",
                "day.ago",
                "last.day"
            )
        } else if timeComponents.hour! > 0 {
            return format(
                timeComponents.hour!,
                numericDates,
                "hours.ago",
                "hour.ago",
                "last.hour"
            )
        } else if timeComponents.minute! > 0 {
            return format(
                timeComponents.minute!,
                numericDates,
                "minutes.ago",
                "minute.ago",
                "last.minute"
            )
        } else if timeComponents.second! >= 3 && secondsInUse {
            return String(
                format: formats["seconds.ago"]!,
                timeComponents.second!
            )
        } else {
            return formats["now"]!
        }
    }

    public func computeTimeAgoSinceNow(
        _ numericDates: Bool,
        formats: [String: String],
        secondsInUse: Bool = true
    ) -> String {
        return computeTimeAgoSince(
            Date(),
            numericDates: numericDates,
            formats: formats,
            secondsInUse: secondsInUse
        )
    }

    public func STDateByAddingDays(_ days: Int) -> Date {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        var components = DateComponents()
        components.day = days

        return (calendar as NSCalendar).date(
            byAdding: components,
            to: self,
            options: NSCalendar.Options(rawValue: 0)
        )!
    }

    public func beginningOfYear(_ currentCalendar: Calendar? = nil) -> Date {
        let calendar = currentCalendar ?? Calendar.current
        var components = (calendar as NSCalendar).components(
            [NSCalendar.Unit.day, NSCalendar.Unit.month, NSCalendar.Unit.year],
            from: self
        )
        components.day = 1
        components.month = 1
        return calendar.startOfDay(for: calendar.date(from: components)!)
    }

    public func endOfYear(_ currentCalendar: Calendar? = nil) -> Date? {
        let calendar = currentCalendar ?? Calendar.current
        return calendar.date(
            byAdding: .year,
            value: 1,
            to: self.beginningOfYear(calendar)
        )
    }

    public func startOfNextYear(_ currentCalendar: Calendar? = nil) -> Date {
        return endOfYear(currentCalendar)!
    }

    public func endOfNextYear(_ currentCalendar: Calendar? = nil) -> Date {
        return startOfNextYear(currentCalendar).addingTimeInterval(1).endOfYear(
            currentCalendar
        )!
    }

    public func lastSecondOfYear(_ currentCalendar: Calendar? = nil) -> Date {
        return startOfNextYear(currentCalendar).addingTimeInterval(-1)
    }

    public func firstSecondOfYear(_ currentCalendar: Calendar? = nil) -> Date {
        return beginningOfYear(currentCalendar).addingTimeInterval(1)
    }

    public func beginningOfMonth(_ currentCalendar: Calendar? = nil) -> Date {
        let calendar = currentCalendar ?? Calendar.current
        let dayInMonth = (calendar as NSCalendar).components(.day, from: self)
            .day!
        var substractComps = DateComponents()
        substractComps.day = -dayInMonth + 1
        let beginningOfMonth = (calendar as NSCalendar).date(
            byAdding: substractComps,
            to: self,
            options: NSCalendar.Options.matchStrictly
        )
        return calendar.startOfDay(for: beginningOfMonth!)
    }

    public func endOfMonth(_ currentCalendar: Calendar? = nil) -> Date? {
        let calendar = currentCalendar ?? Calendar.current
        return calendar.date(
            byAdding: .month,
            value: 1,
            to: self.beginningOfMonth(calendar)
        )
    }

    public func startOfNextMonth(_ currentCalendar: Calendar? = nil) -> Date {
        return endOfMonth(currentCalendar)!
    }

    public func lastSecondOfMonth(_ currentCalendar: Calendar? = nil) -> Date {
        return startOfNextMonth(currentCalendar).addingTimeInterval(-1)
    }

    public func firstSecondOfMonth(_ currentCalendar: Calendar? = nil) -> Date {
        return beginningOfMonth(currentCalendar).addingTimeInterval(1)
    }

    public func beginningOfDay(_ currentCalendar: Calendar? = nil) -> Date {
        let calendar = currentCalendar ?? Calendar.current
        let startOfDay = calendar.startOfDay(for: self)
        return startOfDay
    }

    public func endOfDay(_ currentCalendar: Calendar? = nil) -> Date {
        let calendar = currentCalendar ?? Calendar.current
        var components = DateComponents()
        components.day = 1
        let date = calendar.date(
            byAdding: components,
            to: self.beginningOfDay(calendar)
        )!
        return calendar.startOfDay(for: date)
    }

    public func startOfNextDay(_ currentCalendar: Calendar? = nil) -> Date {
        return endOfDay(currentCalendar)
    }

    public func firstSecondOfDay(_ currentCalendar: Calendar? = nil) -> Date {
        return beginningOfDay(currentCalendar).addingTimeInterval(1)
    }

    public func lastSecondOfDay(_ currentCalendar: Calendar? = nil) -> Date {
        return endOfDay(currentCalendar).addingTimeInterval(-1)
    }

    public func adding(
        _ value: Int,
        component: Calendar.Component,
        calendar: Calendar = .current
    ) -> Date? {
        calendar.date(byAdding: component, value: value, to: self)
    }

    public func addHoursToDate(_ currentCalendar: Calendar? = nil, periods: Int)
        -> Date
    {
        let calendar = currentCalendar ?? Calendar.current
        var components = DateComponents()
        components.hour = periods
        return calendar.date(byAdding: components, to: self)!
    }

    public func addDaysToDate(_ currentCalendar: Calendar? = nil, periods: Int)
        -> Date
    {
        let calendar = currentCalendar ?? Calendar.current
        var components = DateComponents()
        components.day = periods
        return calendar.date(byAdding: components, to: self)!
    }

    public func addMonthsToDate(
        _ currentCalendar: Calendar? = nil,
        periods: Int
    ) -> Date {
        let calendar = currentCalendar ?? Calendar.current
        var components = DateComponents()
        components.month = periods
        return calendar.date(byAdding: components, to: self)!
    }

    public func addYearsToDate(_ currentCalendar: Calendar? = nil, periods: Int)
        -> Date
    {
        let calendar = currentCalendar ?? Calendar.current
        var components = DateComponents()
        components.year = periods
        return calendar.date(byAdding: components, to: self)!
    }

    // NOTE: Whether the currentCalendar is passed in or not here, the rule of the first day of the week currently set by the app is applied.
    public func beginningOfWeek(_ currentCalendar: Calendar? = nil) -> Date {
        let calendar = currentCalendar ?? Calendar.current
        let comps = (calendar as NSCalendar).components(.weekday, from: self)
        var substractComps = DateComponents()
        let subsDays = firstDayOfTheWeek(calendar) - comps.weekday!
        substractComps.day = subsDays > 0 ? subsDays - 7 : subsDays
        let beginningOfWeek = (calendar as NSCalendar).date(
            byAdding: substractComps,
            to: self,
            options: NSCalendar.Options.matchStrictly
        )
        return calendar.startOfDay(for: beginningOfWeek!)
    }

    public func endOfWeek(_ currentCalendar: Calendar? = nil) -> Date {
        let calendar = currentCalendar ?? Calendar.current
        let beginningOfWeek = self.beginningOfWeek(calendar)
        var addComps = DateComponents()
        addComps.day = 7
        let endOfWeek = (calendar as NSCalendar).date(
            byAdding: addComps,
            to: beginningOfWeek,
            options: NSCalendar.Options.matchStrictly
        )
        return endOfWeek!
    }

    public func startOfNextWeek(_ currentCalendar: Calendar? = nil) -> Date {
        return endOfWeek(currentCalendar)
    }

    public func firstSecondOfWeek(_ currentCalendar: Calendar? = nil) -> Date {
        return beginningOfWeek(currentCalendar).addingTimeInterval(1)
    }

    public func lastSecondOfWeek(_ currentCalendar: Calendar? = nil) -> Date {
        return endOfWeek(currentCalendar).addingTimeInterval(-1)
    }

    public func firstSecondOfPreviousWeek(_ currentCalendar: Calendar? = nil)
        -> Date
    {
        return beginningOfPreviousWeek(currentCalendar).addingTimeInterval(1)
    }

    public func lastSecondOfPreviousWeek(_ currentCalendar: Calendar? = nil)
        -> Date
    {
        return endOfPreviousWeek(currentCalendar).addingTimeInterval(-1)
    }

    public func beginningOfPreviousWeek(_ currentCalendar: Calendar? = nil)
        -> Date
    {
        let calendar = currentCalendar ?? Calendar.current
        let beginningOfWeek = self.beginningOfWeek(calendar)
        var addComps = DateComponents()
        addComps.day = -7
        let beginningOfPreviousWeek = (calendar as NSCalendar).date(
            byAdding: addComps,
            to: beginningOfWeek,
            options: NSCalendar.Options.matchStrictly
        )
        return beginningOfPreviousWeek!
    }

    public func endOfPreviousWeek(_ currentCalendar: Calendar? = nil) -> Date {
        let calendar = currentCalendar ?? Calendar.current
        return beginningOfWeek(calendar)
    }

    public func daysToEndOfWeek(_ currentCalendar: Calendar? = nil) -> Int {
        let calendar = currentCalendar ?? Calendar.current
        let endOfWeek = self.endOfWeek(calendar)
        let startOfToday = calendar.startOfDay(for: self)
        let numberOfDays = (calendar as NSCalendar).components(
            .day,
            from: startOfToday,
            to: endOfWeek,
            options: NSCalendar.Options.matchStrictly
        )
        return numberOfDays.day!
    }

    public func weekday() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }

    public static func dateToISOString(_ date: Date, timezone: TimeZone? = nil)
        -> String
    {
        let dateFormatter = Foundation.DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = timezone ?? TimeZone.ReferenceType.local
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        return dateFormatter.string(from: date)
    }

    public func isInSameWeek(date: Date, currentCalendar: Calendar? = nil)
        -> Bool
    {
        var calendar = currentCalendar ?? Calendar.current
        if currentCalendar == nil {
            calendar.firstWeekday = firstDayOfTheWeek(calendar)
        }
        return calendar.isDate(self, equalTo: date, toGranularity: .weekOfYear)
    }

    public func isInSameMonth(date: Date, calendar: Calendar = .current) -> Bool
    {
        return calendar.isDate(self, equalTo: date, toGranularity: .month)
    }

    public func isInSameYear(date: Date, calendar: Calendar = .current) -> Bool
    {
        return calendar.isDate(self, equalTo: date, toGranularity: .year)
    }

    public func isInSameDay(date: Date, calendar: Calendar = .current) -> Bool {
        return calendar.isDate(self, equalTo: date, toGranularity: .day)
    }

    public func roundDateToHour(_ currentCalendar: Calendar? = nil) -> Date? {
        let calendar = currentCalendar ?? Calendar.current
        let components = calendar.dateComponents(
            [.year, .month, .day, .hour],
            from: self
        )
        guard let roundedDate = calendar.date(from: components) else {
            return nil
        }
        return roundedDate
    }

    public func roundDateToNextHour(_ currentCalendar: Calendar? = nil) -> Date?
    {
        let calendar = currentCalendar ?? Calendar.current
        let components = calendar.dateComponents(
            [.year, .month, .day, .hour],
            from: self
        )
        guard let currentHour = components.hour else {
            return nil
        }
        let nextHour = (currentHour + 1) % 24
        let roundedComponents = DateComponents(
            year: components.year,
            month: components.month,
            day: components.day,
            hour: nextHour
        )
        guard let roundedDate = calendar.date(from: roundedComponents) else {
            return nil
        }
        return roundedDate
    }

    public func roundDateToMinute(
        _ rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero
    ) -> Date {
        Date(
            timeIntervalSinceReferenceDate: (timeIntervalSinceReferenceDate
                / 60.0).rounded(rule) * 60.0
        )
    }

    public func daysTo(_ toDate: Date, _ currentCalendar: Calendar? = nil)
        -> Int
    {
        let calendar = currentCalendar ?? Calendar.current
        let components = calendar.dateComponents([.day], from: self, to: toDate)
        if let days = components.day {
            return days
        } else {
            return 0
        }
    }

    public func ensureCurrentTime() -> Date {
        min(self, Date())
    }

    public func firstDayOfTheWeek(_ currentCalendar: Calendar? = nil) -> Int {
        let firstWeekday: Int
        var calendar = currentCalendar ?? Calendar.current
        calendar.locale = Locale.autoupdatingCurrent
        firstWeekday = calendar.firstWeekday
        return firstWeekday
    }
}

extension Date {
    public static func earlierDate(firstDate: Date?, secondDate: Date?) -> Date?
    {
        guard let firstDate = firstDate, let secondDate = secondDate else {
            return firstDate ?? secondDate
        }
        return firstDate > secondDate ? secondDate : firstDate
    }

    public static func laterDate(firstDate: Date?, secondDate: Date?) -> Date? {
        guard let firstDate = firstDate, let secondDate = secondDate else {
            return firstDate ?? secondDate
        }
        return firstDate < secondDate ? secondDate : firstDate
    }
}

extension Date {
    public func yearsSince(referenceYear: Int) -> Int? {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = referenceYear
        components.month = 1
        components.day = 1

        guard let fromDate = calendar.date(from: components) else {
            return nil
        }
        let yearsDifference = calendar.dateComponents(
            [.year],
            from: fromDate,
            to: self
        ).year
        return yearsDifference
    }

    public func replaceYear(newYear: Int) -> Date? {
        let calendar = Calendar.current
        var components = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: self
        )
        components.year = newYear
        return calendar.date(from: components)
    }

    public var yearOfDate: Int? {
        let calendar = Calendar.current
        return calendar.dateComponents([.year], from: self).year
    }
}

extension Date {
    public var startOfNextDay: Date {
        return Calendar.current.nextDate(
            after: self,
            matching: DateComponents(hour: 0, minute: 0),
            matchingPolicy: .nextTimePreservingSmallerComponents
        )!
    }

    public var secondsUntilTheNextMidnight: TimeInterval {
        return startOfNextDay.timeIntervalSince(self)
    }

    public var secondsSinceThePreviousMidnight: TimeInterval {
        return (3600.0 * 24.0) - secondsUntilTheNextMidnight
    }

    public func checkTimeDifference(_ another: Date) -> Bool {
        let calendar = Calendar.current
        let selfComponents = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: self
        )
        let anotherComponets = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: another
        )
        return selfComponents.year == anotherComponets.year
            && selfComponents.month == anotherComponets.month
            && selfComponents.day == anotherComponets.day
            && selfComponents.hour == anotherComponets.hour
            && selfComponents.minute == anotherComponets.minute
    }
}

extension String {
    public var utcDate: Date? {
        let formatter = Foundation.DateFormatter()
        if let identifier = Locale.preferredLanguages.first {
            formatter.locale = Locale(identifier: identifier)
        }
        let timeZone = TimeZone(secondsFromGMT: 0)!
        formatter.timeZone = timeZone
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        let utcDate = formatter.date(from: self)
        return utcDate
    }
}

extension Calendar {
    public func percentageOfDay(for date: Date) -> Double {
        let startOfDay = self.startOfDay(for: date)
        let secondsSinceStartOfDay = date.timeIntervalSince(startOfDay)
        let oneDay = DateComponents(calendar: self, day: 1)

        if let nextDay = self.date(byAdding: oneDay, to: date) {
            let startOfNextDay = self.startOfDay(for: nextDay)
            let secondsInDay = startOfNextDay.timeIntervalSince(startOfDay)

            return secondsSinceStartOfDay / secondsInDay
        } else {
            return secondsSinceStartOfDay / (24 * 60 * 60)  // Default to assuming every day has 24 hours.
        }
    }
}

private class _DateRangeFormatter {
    var locale: Locale = .current
    init(locale: Locale) {
        self.locale = locale
    }

    lazy var dateFormatter: Foundation.DateFormatter = {
        let df = Foundation.DateFormatter()
        df.locale = locale
        df.setLocalizedDateFormatFromTemplate("MMM d")
        return df
    }()

    lazy var timeFormatter: Foundation.DateFormatter = {
        let tf = Foundation.DateFormatter()
        tf.locale = locale
        tf.setLocalizedDateFormatFromTemplate("HH:mm")
        return tf
    }()

    func string(from start: Date, to end: Date) -> String {
        let datePart = dateFormatter.string(from: start)
        let startTime = timeFormatter.string(from: start)
        let endTime = timeFormatter.string(from: end)
        return "\(datePart), \(startTime)-\(endTime)"
    }
}

extension Range where Bound == Date {
    public func formattedTimeRange(locale: Locale = .current) -> String {
        let formatter = _DateRangeFormatter(locale: locale)
        return formatter.string(from: lowerBound, to: upperBound)
    }
}

extension ClosedRange where Bound == Date {
    public func formattedTimeRange(locale: Locale = .current) -> String {
        let formatter = _DateRangeFormatter(locale: locale)
        return formatter.string(from: lowerBound, to: upperBound)
    }
}
