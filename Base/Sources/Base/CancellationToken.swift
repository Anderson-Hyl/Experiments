import Foundation

@available(watchOS 6.0, *)
public actor CancellationToken {
    private var _isCancelled = false
    
    public init() {
        self._isCancelled = false
    }
    
    public func cancel() {
        _isCancelled = true
    }
    
    public func isCancelled() -> Bool {
        _isCancelled
    }
    
    public func checkCancelled() throws {
        if _isCancelled {
            throw Self.CancellationError()
        }
    }
    
    public struct CancellationError: Error {}
}
