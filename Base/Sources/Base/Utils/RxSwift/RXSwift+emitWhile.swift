import Foundation
import RxSwift

// https://gist.github.com/danielt1263/ec1032375498eb95aa260239b289d263
/**
 Calls `producer` with `seed` then emits result and also passes it to `pred`. Will continue to call
 `producer` with new values as long as `pred` returns values.
 
 - parameter seed: The starting value needed for the first producer call.
 - parameter pred: A closure that determines the next value pass into the producer or returns nil if no
 more calls are necessary.
 - parameter producer: A closure that returns a Single.
 - returns: An observable that emits each producer's value.
 */
public func emitWhile<T, U>(seed: U, pred: @escaping (T) -> U?, producer: @escaping (U) -> Single<T>) -> Observable<T> {
    producer(seed)
        .asObservable()
        .flatMap { (result) -> Observable<T> in
            guard let value = pred(result) else { return .just(result) }
            return emitWhile(seed: value, pred: pred, producer: producer)
                .startWith(result)
        }
}
