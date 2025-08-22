import Foundation

public protocol Transport {
    func send(_ data: Data) async
    func receive() async -> Data?
}

public class InMemoryTransport: Transport {
    private let incoming: AsyncStream<Data>
    private let push: (Data) -> Void
    public init(incoming: AsyncStream<Data>, push: @escaping (Data) -> Void) {
        self.incoming = incoming
        self.push = push
    }
    public func send(_ data: Data) async {
        push(data)
    }
    public func receive() async -> Data? {
        var it = incoming.makeAsyncIterator()
        return await it.next()
    }
}

public func makeTransportPair() -> (some Transport, some Transport) {
    var contA: AsyncStream<Data>.Continuation!
    var contB: AsyncStream<Data>.Continuation!
    let streamA = AsyncStream<Data> { contA = $0 }
    let streamB = AsyncStream<Data> { contB = $0 }
    let tA = InMemoryTransport(incoming: streamA) { contB.yield($0) }
    let tB = InMemoryTransport(incoming: streamB) { contA.yield($0) }
    return (tA, tB)
}

public func packFrame(_ payload: Data) -> Data {
    var len = UInt32(payload.count).bigEndian
    var data = Data(bytes: &len, count: 4)
    data.append(payload)
    return data
}

public func unpackFrames(from buffer: inout Data) -> [Data] {
    var frames: [Data] = []
    while buffer.count >= 4 {
        let len = buffer.prefix(4).withUnsafeBytes { $0.load(as: UInt32.self).bigEndian }
        guard buffer.count >= 4 + Int(len) else { break }
        buffer.removeFirst(4)
        frames.append(buffer.prefix(Int(len)))
        buffer.removeFirst(Int(len))
    }
    return frames
}
