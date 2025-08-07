@propertyWrapper
public struct Clamped<Value: Comparable> {
    private var value: Value
    private let range: ClosedRange<Value>
    
    public init(wrappedValue: Value, _ range: ClosedRange<Value>) {
        self.value = min(max(range.lowerBound, wrappedValue), range.upperBound)
        self.range = range
    }
    
    public var wrappedValue: Value {
        get { value }
        set {
            value = min(max(range.lowerBound, newValue), range.upperBound)
        }
    }
}
