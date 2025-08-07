public struct AsyncResource<Value, E: Error> {
    public var value: Value?
    public var isLoading: Bool = false
    public var error: E?
    
    public init(value: Value? = nil, isLoading: Bool = false, error: E? = nil) {
        self.value = value
        self.isLoading = isLoading
        self.error = error
    }
}

extension AsyncResource: Equatable where Value: Equatable, E: Equatable {}
extension AsyncResource: Hashable where Value: Hashable, E: Hashable {}
