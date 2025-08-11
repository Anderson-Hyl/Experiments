//
//  ClosedRange_.swift
//  Experiment
//
//  Created by anderson on 2025/8/4.
//

import Foundation

// MARK: - Subranges extension

public extension ClosedRange {
    /**
     Returns an array of subranges with gaps with excludedRanges removed.
     
     The result is undefined if `excludedRanges`:
     * are not in an ascending order
     * overlap (bounds may touch)
     
     - returns:
     An array of closed range elements including elements of this range and bounds of excluded
     ranges but no values between excluded range bounds.
     
     - parameters:
     - excludedRanges: the gaps in resulting ranges
     
     - Precondition: `excludedRanges` must be in ascending order and non-overlapping. Bounds may touch.
     */
    func subranges(excluding excludedRanges: [ClosedRange<Bound>]) -> [ClosedRange<Bound>] {
        precondition(excludedRanges.isAscendingAndNonOverlapping())
        
        var results: [ClosedRange<Bound>] = []
        var currentLowerBound = lowerBound
        for excludedRange in excludedRanges {
            if contains(excludedRange.lowerBound) && currentLowerBound < excludedRange.lowerBound {
                results.append(currentLowerBound...excludedRange.lowerBound)
            }
            
            if excludedRange.lowerBound <= upperBound || excludedRange.upperBound < upperBound {
                currentLowerBound = Swift.max(lowerBound, excludedRange.upperBound)
            }
        }
        
        if (lowerBound..<upperBound).contains(currentLowerBound) {
            results.append(currentLowerBound...upperBound)
        }
        
        return results
    }
}

private extension Array {
    func isAscendingAndNonOverlapping<T>() -> Bool where Element == ClosedRange<T> {
        return zip(dropLast(), dropFirst()).allSatisfy { (before, after) -> Bool in
            return before.upperBound <= after.lowerBound
        }
    }
}

// MARK: - Date extension for binned analysis

public extension ClosedRange where Bound == Date {
    var timeInterval: TimeInterval {
        return upperBound.timeIntervalSince(lowerBound)
    }
    
    /** This function is useful for binned analysis
     
     - If no slices of `slicesOf` fit into range -> empty result.
     - If it doesn't fit evently, bit from the end is not covered by produced the ranges.
     */
    func sliceTo(slicesOf sliceLength: TimeInterval) -> [ClosedRange<Date>] {
        let numberOfSlices = Int(floor(timeInterval / sliceLength))
        return (0..<numberOfSlices).map { index in
            let lower = lowerBound.addingTimeInterval(TimeInterval(index) * sliceLength)
            let upper = lowerBound.addingTimeInterval(TimeInterval(index + 1) * sliceLength)
            return lower...upper
        }
    }
}

extension ClosedRange where Bound: BinaryInteger {
    func toDoubleRange() -> ClosedRange<Double> {
        return Double(self.lowerBound)...Double(self.upperBound)
    }
}

extension ClosedRange where Bound: Comparable {
    var isSinglePoint: Bool {
        return lowerBound == upperBound
    }
}

extension ClosedRange where Bound: Numeric {
    var isZeroSinglePoint: Bool {
        return lowerBound == 0 && upperBound == 0
    }
}
