#if os(iOS)
import UIKit
#elseif os(watchOS)
import WatchKit
#endif

public extension Sequence where Iterator.Element == Int {
    var sum: Int {
        return reduce(0, +)
    }
}

public extension Sequence where Iterator.Element == Double {
    var sum: Double {
        return reduce(Double(), +)
    }
}

public extension Sequence {
    var first: Self.Element? {
        var iterator = self.makeIterator()
        return iterator.next()
    }
}

public extension Sequence {
    func pairs() -> AnySequence<(Element, Element)> {
        return AnySequence(zip(self, self.dropFirst()))
    }
}

public extension Sequence {
    func findAndMapFirst<O>(_ mapping: (Self.Iterator.Element) throws -> O?) rethrows -> O? {
        for element in self {
            let potentialResult = try mapping(element)
            if potentialResult != nil {
                return potentialResult
            }
        }
        return nil
    }
}

public extension Sequence {
    func scan<T>(_ initial: T, combine: (_ accumulator: T, _ element: Iterator.Element) throws -> T) rethrows -> [T] {
        var accu = initial
        return try map { e in
            accu = try combine(accu, e)
            return accu
        }
    }
    
    /// This works as scan, but includes the initial value in the result
    /// - parameter initial:    The initial value.
    /// - parameter combine:    The function that combines the new value to the accumulated one.
    /// - parameter accumulator:The previous result of combine call (or the initial value).
    /// - parameter element:    The next element to combine to the accumulated one.
    /// - Returns: An array with results of combine invocations.
    func scanInclusive<T>(_ initial: T, combine: (_ accumulator: T, _ element: Iterator.Element) throws -> T) rethrows -> [T] {
        var accu = initial
        return try [initial] + map { e in
            accu = try combine(accu, e)
            return accu
        }
    }
    
    func mapWithState<A, T>(_ initial: A, combine: (_ accumulator: A, _ element: Iterator.Element) throws -> (A, T)) rethrows -> [T] {
        var accu: A = initial
        return try map { e in
            let midResult = try combine(accu, e)
            accu = midResult.0
            return midResult.1
        }
    }
    
    func find(_ predicate: (Self.Iterator.Element) throws -> Bool) rethrows -> Self.Iterator.Element? {
        for element in self {
            if try predicate(element) {
                return element
            }
        }
        return nil
    }
    
    func memmap<T>(_ transform: (_ prev: Self.Iterator.Element?, _ curr: Self.Iterator.Element) throws -> T) rethrows -> [T] {
        var accu = [T]()
        var prev: Self.Iterator.Element?
        for element in self {
            let val = try transform(prev, element)
            accu.append(val)
            prev = element
        }
        return accu
    }
    
    func forEachWithNext(_ apply: (_ curr: Self.Iterator.Element, _ next: Self.Iterator.Element?) throws -> Void) rethrows {
        var prev: Self.Iterator.Element?
        for element in self {
            if let prevValue = prev {
                try apply(prevValue, element)
            }
            prev = element
        }
        if let prevValue = prev {
            try apply(prevValue, nil)
        }
    }
    
    func takeBetween<T>(range: Range<T>, key: (Element) -> (T)) -> [Self.Element] where T: Comparable {
        let prefix = drop(while: { key($0) <= range.lowerBound })
            .prefix(while: { key($0) < range.upperBound })
        
        // In Swift 5, `.prefix(while:)` already returns an array. As long as we need to
        // support Xcode 10.1 and lower, we have manually create an `Array` from the `SubSequence`.
        return Array(prefix)
    }
    
    typealias Reducer<R> = (R, Element) -> R
    
    func binAndReduce<T, R>(to bins: [ClosedRange<T>],
                            withReducer: Reducer<R>,
                            initially: R,
                            key: (Element) -> (T)) -> [R] where T: Comparable {
        var elementIterator = makeIterator()
        var binIterator = bins.makeIterator()
        var results: [R] = []
        
        var state: ReducingState<Element> = .fillingBin
        while let bin = binIterator.next() {
            var reducedState = initially
            
            if case ReducingState<Element>.lookingForBinForElement(let element) = state {
                if bin.contains(key(element)) {
                    reducedState = withReducer(reducedState, element)
                    state = .fillingBin
                } else if bin.lowerBound >= key(element) {
                    state = .fillingBin
                }
            }
            
            while state.shouldLookForNextElement(key: key, bound: bin.lowerBound), let element = elementIterator.next() {
                if bin.contains(key(element)) {
                    reducedState = withReducer(reducedState, element)
                } else {
                    state = .lookingForBinForElement(element)
                }
            }
            results.append(reducedState)
        }
        return results
    }
}

private enum ReducingState<Element> {
    case lookingForBinForElement(Element)
    case fillingBin
    
    func shouldLookForNextElement<T>(key: (Element) -> T, bound: T) -> Bool where T: Comparable {
        switch self {
        case .lookingForBinForElement(let element):
            return key(element) < bound
        case .fillingBin:
            return true
        }
    }
}
