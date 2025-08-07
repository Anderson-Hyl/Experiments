import Foundation

/**
 Round with exact amount of decimal places.
 */
public func round(_ value: Double, places: Int) -> Double {
    let divisor = pow(10.0, Double(places))
    return round(value * divisor) / divisor
}

public func restrict<T: FloatingPoint>(_ value: T, from: T, to: T) -> T {
    return max(from, min(value, to))
}

public func unboundProgress<T: FloatingPoint>(_ value: T, from: T, to: T) -> T {
    return (value - from) / (to - from)
}

public func boundProgress<T: FloatingPoint>(_ value: T, from: T, to: T) -> T {
    return restrict(unboundProgress(value, from: from, to: to), from: T(0), to: T(1))
}

public func applyProgress<T: FloatingPoint>(_ progress: T, from: T, to: T) -> T {
    return from + (to - from) * progress
}

public func delay(_ delay: TimeInterval, handler: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * TimeInterval(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: handler)
}

public func partial<A, B, T>(_ f: @escaping (A, B) -> T, a: A) -> (B) -> T {
    return { f(a, $0) }
}

public func degreesToRadians<T: FloatingPoint>(_ value: T) -> T {
    return value * T.pi / T(180)
}

public func radiansToDegrees<T: FloatingPoint>(_ value: T) -> T {
    return value * T(180) / T.pi
}

public func findIndex<T>(_ array: [T], callback: (T) -> Bool) -> Int? {
    for (index, elem): (Int, T) in array.enumerated() {
        if callback(elem) {
            return index
        }
    }
    return .none
}

public func computeGoalProgress(achievedValue: Double, goal: Double) -> Double {
    if achievedValue > 0 && goal > 0 {
        return min(achievedValue / goal, 1)
    }
    
    return achievedValue > 0 ? 1 : 0
}

public func zip<A, B>(_ optional1: A?, _ optional2: B?) -> (A, B)? {
    guard let a = optional1, let b = optional2 else { return nil }
    return (a, b)
}
