import ConcurrencyExtras
@preconcurrency import Foundation
import Sharing
import Synchronization

extension SharedKey {
    public static func uuidAppStorage(
        _ key: String,
        store: UserDefaults = .standard
    ) -> Self where Self == DataRepresentableAppStorageKey<UUID?> {
        DataRepresentableAppStorageKey(
            key: key,
            store: .standard,
            decode: { data in
                // 尝试用 Data 构造 UUID
                guard data.count == MemoryLayout<UUID>.size else {
                    throw NSError(
                        domain: "UUIDAppStorageKey",
                        code: -1,
                        userInfo: [
                            NSLocalizedDescriptionKey: "Invalid UUID data"
                        ]
                    )
                }
                return data.withUnsafeBytes { rawBuffer in
                    let bytes = rawBuffer.bindMemory(to: UInt8.self)
                    return UUID(
                        uuid: (
                            bytes[0], bytes[1], bytes[2], bytes[3],
                            bytes[4], bytes[5], bytes[6], bytes[7],
                            bytes[8], bytes[9], bytes[10], bytes[11],
                            bytes[12], bytes[13], bytes[14], bytes[15]
                        )
                    )
                }
            },
            encode: { uuid in
                var u = uuid?.uuid
                return withUnsafeBytes(of: &u) { Data($0) }
            }
        )
    }
    public static func dataRepresentableAppStorageKey<Value: Sendable>(
        _ key: String,
        store: UserDefaults = .standard,
        decode: @escaping @Sendable (Data) throws -> Value,
        encode: @escaping @Sendable (Value) -> Data
    ) -> Self where Self == DataRepresentableAppStorageKey<Value> {
        DataRepresentableAppStorageKey(
            key: key,
            store: .standard,
            decode: decode,
            encode: encode
        )
    }
}

public final class DataRepresentableAppStorageKey<Value: Sendable>: SharedKey {
    private let key: String
    private let decode: @Sendable (Data) throws -> Value
    private let encode: @Sendable (Value) throws -> Data
    private let store: UncheckedSendable<UserDefaults>
    fileprivate init(
        key: String,
        store: UserDefaults = .standard,
        decode: @escaping @Sendable (Data) throws -> Value,
        encode: @escaping @Sendable (Value) throws -> Data,
    ) {
        self.key = key
        self.store = UncheckedSendable(store)
        self.decode = decode
        self.encode = encode
    }

    public var id: DataRepresentationAppStorageKeyID {
        DataRepresentationAppStorageKeyID(
            key: key,
            store: store.wrappedValue
        )
    }

    public struct DataRepresentationAppStorageKeyID: Hashable {
        fileprivate let key: String
        fileprivate let store: UserDefaults
    }

    public func load(
        context: LoadContext<Value>,
        continuation: LoadContinuation<Value>
    ) {
        switch context {
        case .initialValue(let initialValue):
            guard let data = store.wrappedValue.data(forKey: key) else {
                continuation.resume(returning: initialValue)
                return
            }
            do {
                let value = try decode(data)
                continuation.resume(returning: value)
            } catch {
                continuation.resume(returning: initialValue)
            }
        case .userInitiated:
            guard let data = store.wrappedValue.data(forKey: key) else {
                continuation.resumeReturningInitialValue()
                return
            }
            do {
                let value = try decode(data)
                continuation.resume(returning: value)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    public func subscribe(
        context: LoadContext<Value>,
        subscriber: SharedSubscriber<Value>
    ) -> SharedSubscription {
        let defaults = store.wrappedValue
        let initial = context.initialValue  // 官方 demo 在 subscribe 里也会拿到初始值

        // 读取当前值（不存在时返回默认/初始值）
        @Sendable func lookupValue(default initialValue: Value?) -> Value? {
            guard let data = store.wrappedValue.data(forKey: key) else {
                return initialValue
            }
            do {
                return try decode(data)
            } catch {
                return initialValue
            }
        }

        // 线程安全缓存上一发出的值
        let previousValue = Mutex(initial)

        // 运行时等价判断：若 Value 遵守 Equatable，用 == 去重，否则返回 nil 表示“无法比较”
        @Sendable func isEqual<T>(_ lhs: T, _ rhs: T) -> Bool? {
            func open<U: Equatable>(_ lhs: U) -> Bool {
                lhs == (rhs as? U)
            }
            guard let lhs = lhs as? any Equatable else { return nil }
            return open(lhs)
        }

        // 订阅目标 defaults 的变化
        let token = NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: defaults,
            queue: nil
        ) { _ in
            // 计算新值（失败/缺失用 initial 兜底，以匹配官方 load/subscribe 语义）
            let newValue = lookupValue(default: initial)

            // 去重逻辑：
            // - 如果能比较且和上一值相等 => 不下发
            // - 如果不能比较（Not Equatable），保守下发
            // - 兼容 initial 语义：如果"等于 initial"（或无法比较）也允许下发
            let prev = previousValue.withLock { $0 }
            let equalToPrev = isEqual(newValue, prev) ?? false
            let equalToInitial = isEqual(newValue, initial) ?? true
            guard !equalToPrev || equalToInitial else {
                return
            }

            // 自写入回声抑制：save 时会把 isSetting 标记成 true，这里直接跳过
            guard !SharedAppStorageLocals.isSetting else { return }

            // 记下新值（放在 yield 之前防止竞态）
            previousValue.withLock { $0 = newValue }

            // 主线程派发（与官方行为一致）
            DispatchQueue.main.async {
                subscriber.yield(with: .success(newValue))
            }
        }
        let removeObserver: @Sendable () -> Void = {
            NotificationCenter.default.removeObserver(token)
        }
        return SharedSubscription(removeObserver)
    }

    // 建议把 save 也按官方语义包一层“自写入回声抑制”
    public func save(
        _ value: Value,
        context: SaveContext,
        continuation: SaveContinuation
    ) {
        do {
            let data = try encode(value)
            SharedAppStorageLocals.$isSetting.withValue(true) {
                store.wrappedValue.set(data, forKey: key)
            }
            continuation.resume()
        } catch {
            continuation.resume(throwing: error)
        }
    }
}

private enum SharedAppStorageLocals {
    @TaskLocal static var isSetting = false
}
