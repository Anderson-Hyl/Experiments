
import Foundation

public extension FixedWidthInteger {
    /// Creates an integer from the given floating-point value, rounding toward zero.
    ///
    /// - If the value is `NaN`, the result is `0`.
    /// - If the value is infinite, the result is `Self.min` or `Self.max` depending on the sign.
    /// - If the value is outside the bounds of this type after rounding toward zero, it is clamped to `Self.min` or `Self.max`.
    ///
    /// - Parameter source: The floating-point value to convert.
    init<T>(truncating source: T) where T: BinaryFloatingPoint {
        if source.isNaN {
            self = 0 // Is it a good idea to map nan to zero?
        } else if source.isInfinite {
            self = source.sign == .minus ? Self.min : Self.max
        } else {
            let roundedValue = source.rounded(.towardZero)
            let minValue = T(Self.min)
            let maxValue = T(Self.max)
            
            if roundedValue < minValue.nextUp {
                self = Self.min
            } else if roundedValue > maxValue.nextDown {
                self = Self.max
            } else {
                self = Self(roundedValue)
            }
        }
    }
    
    /// Initializes an integer from a floating-point value, rounding according to the specified rule.
    ///
    /// - If the value is `NaN`, the result is `0`.
    /// - If the value is infinite, the result is `Self.min` or `Self.max` depending on the sign.
    /// - If the value is outside the bounds of this type after rounding toward zero, it is clamped to `Self.min` or `Self.max`.
    ///
    /// - Parameters:
    ///   - value: The floating-point value to convert.
    ///   - roundingRule: The rounding rule to use. Defaults to `.toNearestOrAwayFromZero`.
    init<T: BinaryFloatingPoint>(rounding source: T, roundingRule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) {
        if source.isNaN {
            self = 0 // Is it a good idea to map nan to zero?
        } else if source.isInfinite {
            self = source.sign == .minus ? Self.min : Self.max
        } else {
            let roundedValue = source.rounded(roundingRule)
            let minValue = T(Self.min)
            let maxValue = T(Self.max)
            
            if roundedValue < minValue.nextUp {
                self = Self.min
            } else if roundedValue > maxValue.nextDown {
                self = Self.max
            } else {
                self = Self(roundedValue)
            }
        }
    }
    
    /// Initializes an integer from a floating-point value, optionally rounding according to the specified rule.
    ///
    /// Returns `nil` if the value is not finite, or if it is outside the representable range of the integer type.
    ///
    /// - Parameters:
    ///   - value: The floating-point value to convert.
    ///   - roundingRule: The rounding rule to use. If `nil`, the value is used as-is without rounding.
    init?<T: BinaryFloatingPoint>(roundingOptionally value: T, roundingRule: FloatingPointRoundingRule?) {
        guard value.isFinite else {
            return nil
        }
        
        let adjustedValue: T
        if let rule = roundingRule {
            adjustedValue = value.rounded(rule)
        } else {
            adjustedValue = value
        }
        
        let minValue = T(Self.min)
        let maxValue = T(Self.max)
        
        if adjustedValue < minValue.nextUp {
            self = Self.min
        } else if adjustedValue > maxValue.nextDown {
            self = Self.max
        } else {
            self = Self(adjustedValue)
        }
    }
    
    var nilForZero: Self? {
        self == 0 ? nil : self
    }
    
    func fromPercentageToDouble() -> Double {
        Double(self) / 100
    }
    
    func roundToNearest(base: Self) -> Self {
        return ((self + base / 2) / base) * base
    }
}

public extension BinaryFloatingPoint {
    func asIntTruncating() -> Int {
        Int(truncating: self)
    }
    
    func asIntRounding(roundingRule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> Int {
        Int(rounding: self, roundingRule: roundingRule)
    }
    
    func clamped(minimum: Self, maximum: Self) -> Self {
        return min(max(self, minimum), maximum)
    }
}

public extension Double {
    func roundedTo(_ places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    func modulo(_ modulo: Double, rule: FloatingPointRoundingRule) -> Double {
        (self / modulo).rounded(rule) * modulo
    }
    
    static var maxValue: Double {
        return .greatestFiniteMagnitude
    }
    
    static var minValue: Double {
        return .leastNormalMagnitude
    }
}

public extension Optional where Wrapped: BinaryInteger {
    var positiveOrNil: Wrapped? {
        guard let value = self, value > 0 else { return nil }
        return value
    }
}

public extension Optional where Wrapped: BinaryFloatingPoint {
    var positiveOrNil: Wrapped? {
        guard let value = self, value > 0 else { return nil }
        return value
    }
}
