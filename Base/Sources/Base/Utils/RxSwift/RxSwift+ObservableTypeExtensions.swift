import Foundation
import RxRelay
import RxSwift

public extension ObservableType {
    func subscribeNext(_ f: ((Self.Element) -> Void)?) -> Disposable {
        return subscribe(onNext: f, onError: nil, onCompleted: nil, onDisposed: nil)
    }
    
    func subscribeError(_ f: ((Error) -> Void)?) -> Disposable {
        return subscribe(onNext: nil, onError: f, onCompleted: nil, onDisposed: nil)
    }
    
    func subscribeCompleted(_ f: (() -> Void)?) -> Disposable {
        return subscribe(onNext: nil, onError: nil, onCompleted: f, onDisposed: nil)
    }
    
    func doOnNext(_ f: ((Self.Element) -> Void)?) -> Observable<Self.Element> {
        return self.do(onNext: f, onError: nil, onCompleted: nil, onSubscribe: nil, onDispose: nil)
    }
    
    func doOnError(_ f: ((Error) -> Void)?) -> Observable<Self.Element> {
        return self.do(onNext: nil, onError: f, onCompleted: nil, onSubscribe: nil, onDispose: nil)
    }
    
    func doOnCompleted(_ f: (() -> Void)?) -> Observable<Self.Element> {
        return self.do(onNext: nil, onError: nil, onCompleted: f, onSubscribe: nil, onDispose: nil)
    }
}

public extension ObservableType {
    func shareEternally() -> Observable<Element> {
        return self.share(replay: 1, scope: .forever)
    }
    
    // Ensures that observable has always a value when subscribed. At most one subscription is active at
    // given time to the source observable. This count is zero when there are no subscriptions to this
    // observable. When this observable is subscribed into, it replays latest value available.
    func shareEternally(withInitialValue initialValue: Element) -> Observable<Element> {
        return self.multicast(BehaviorSubject(value: initialValue)).refCount()
    }
}

public extension ObservableType {
    func nwise(_ n: Int) -> Observable<[Element]> {
        assert(n > 1, "n must be greater than 1")
        return self
            .scan([]) { acc, item in Array((acc + [item]).suffix(n)) }
            .filter { $0.count == n }
    }
    
    func pairwise() -> Observable<(Element, Element)> {
        return self.nwise(2)
            .map { ($0[0], $0[1]) }
    }
}

public extension ObservableType {
    /**
     Similar to `zip` operator but instead of applying the combining function `resultSelector` on the next items in sequence
     `zipLatest` applies it on the latest items in sequence of the source observables.
     
        Example:
     
            -A------B--C--D---------E---------|
            ---1------------2---------3----4--|
     
                    [zipLatest]
     
            ---A1-----------D2--------E3------|
     
        - returns: An observable sequence containing the result of combining the latest elements of the sources.
     */
    static func zipLatest<O1, O2>(_ source1: O1, _ source2: O2, resultSelector: @escaping (O1.Element, O2.Element) throws -> Self.Element) -> Observable<Self.Element> where O1: ObservableType, O2: ObservableType {
        typealias CombinedEnumeratedO1O2 = ((Int, O1.Element), (Int, O2.Element), Bool)
        
        return Observable.combineLatest(source1.enumerated(), source2.enumerated()).scan(CombinedEnumeratedO1O2?(nil)) { previous, pair in
            guard let previous = previous else { return (pair.0, pair.1, true) }
            guard previous.0.0 != pair.0.0, previous.1.0 != pair.1.0 else { return (previous.0, previous.1, false) }
            return (pair.0, pair.1, true)
        }
        .map { ($0!.0, $0!.1, $0!.2) }
        .filter { $0.2 }
        .map { try resultSelector($0.0.1, $0.1.1) }
    }
    
    static func zipLatest<O1, O2>(_ source1: O1, _ source2: O2) -> Observable<(O1.Element, O2.Element)> where O1: ObservableType, O2: ObservableType, Self.Element == (O1.Element, O2.Element) {
        zipLatest(source1, source2, resultSelector: { ($0, $1) })
    }
}

public extension ObservableType {
    /// Turns the receiver to an infallible where the elements are Result objects.
    func mapToResult() -> Infallible<Result<Element, Error>> {
        materialize().map { event -> Event<Result<Element, Error>> in
            switch event {
            case .next(let nextValue): return .next(.success(nextValue))
            case .completed: return .completed
            case .error(let error): return .next(.failure(error))
            }
        }.dematerialize()
            .asInfallible(onErrorRecover: { error -> Infallible<Result<Element, Error>> in
                .just(.failure(error))
        })
    }
    
    /// Projects each element of an observable sequence to an infallible sequence and merges the resulting infallible sequences into one observable sequence.
    func flatMapToResult<Source>(_ selector: @escaping (Self.Element) throws -> Source) -> RxSwift.Observable<Result<Source.Element, Error>> where Source: RxSwift.ObservableConvertibleType {
        flatMap { item -> Infallible<Result<Source.Element, Error>> in
            try selector(item).asObservable().mapToResult()
        }
    }
    
    /// Projects each element of an observable sequence to an infallible sequence and producing values only from the most recent infallible sequence.
    func flatMapLatestToResult<Source>(_ selector: @escaping (Self.Element) throws -> Source) -> RxSwift.Observable<Result<Source.Element, Error>> where Source: RxSwift.ObservableConvertibleType {
        flatMapLatest { item -> Infallible<Result<Source.Element, Error>> in
            try selector(item).asObservable().mapToResult()
        }
    }
}
