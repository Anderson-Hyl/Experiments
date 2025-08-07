import Foundation

public extension Numeric {
    /// Snaps a given numeric value to a list of numeric values
    /// If the receiver is not in min/max range of the list of numeric values it returns the receiver.
    /// - Parameter values: numeric values
    /// - Returns: the snapped value
    func snapped(to values: [Self]) -> Self where Self: Comparable & Strideable {
        let sortedValues = values.sorted()
        
        guard let first = sortedValues.first, let last = sortedValues.last, first != last, (first...last).contains(self) else { return self }
        
        let distances = sortedValues.map { abs(self.distance(to: $0)) }
        
        guard let shortest = distances.min() else { return self }
        
        let result = distances.firstIndex(of: shortest).map { sortedValues[$0] } ?? self
        
        return result
    }
}

public extension BinaryFloatingPoint {
    /// Snaps a value to the nearest bound within a specified range if it is within a threshold distance.
    /// - Parameters:
    ///   - range: The range within which the value will be snapped.
    ///   - threshold: The maximum distance from a range bound to snap the value to that bound.
    /// - Returns: The value snapped to the closest bound or the original value if it is outside the threshold.
    func snappedToNearestBound(in range: ClosedRange<Self>, threshold: Self = 0.01) -> Self {
        if abs(self - range.lowerBound) < threshold {
            return range.lowerBound
        } else if abs(self - range.upperBound) < threshold {
            return range.upperBound
        }
        return self
    }
    
    /// Snaps a value to 0 or 1 if it is within a threshold distance.
    /// - Parameter threshold: The maximum distance from 0 or 1 to snap the value.
    /// - Returns: The value snapped to 0 or 1, or the original value if it is outside the threshold.
    func snappedToZeroOrOne(threshold: Self = 0.01) -> Self {
        return self.snappedToNearestBound(in: 0...1, threshold: threshold)
    }
}
