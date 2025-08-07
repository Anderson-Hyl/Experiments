import Foundation

public extension Array {
    func distinct<K: Hashable>(_ extractKey: (Element) -> K) -> Self {
        var set = Set<K>()
        return filter {
            let key = extractKey($0)
            guard !set.contains(key) else { return false }
            set.insert(key)
            return true
        }
    }
    
    static func chunking(from: Element, through: Element, by: Element.Stride) -> [Element] where Element: Strideable {
        return Self(Swift.stride(from: from, through: through, by: by))
    }
}

public extension Array where Element: Equatable {
    private struct Unique<T, Key>: Identifiable {
        let id = UUID()
        var key: Key
        let value: T
    }
    
    // selector: (previous, current) -> Bool, if select current
    func distinctBy<K: Hashable>(extractKey: (Element) -> K, selector: (_ previous: Element, _ current: Element) -> Bool) -> Self {
        var mapping: [K: Unique<Element, K>] = [:]
        var sequence: [Unique] = self.map { Unique(key: extractKey($0), value: $0) }
        
        sequence.forEach { current in
            if let old = mapping[current.key] {
                if selector(old.value, current.value) {
                    mapping[current.key] = current
                    sequence.removeAll { $0.id == old.id }
                } else {
                    mapping[current.key] = old
                    sequence.removeAll { $0.id == current.id }
                }
            } else {
                mapping[current.key] = current
            }
        }
        return sequence.map { $0.value }
    }
}
