import Foundation
import RxRelay
import RxSwift

public class BehaviorObservable<Element>: ObservableType {
    public typealias E = Element
    private let disposeBag = DisposeBag()
    private let subject: BehaviorSubject<Element>
    
    public func value() -> Element {
        return try! subject.value()
    }
    
    public init(source: BehaviorSubject<Element>) {
        subject = source
    }
    
    public convenience init(value: Element, source: Observable<Element>) {
        self.init(source: BehaviorSubject<Element>(value: value))
        source.startWith(value).subscribe(subject).disposed(by: disposeBag)
    }
    
    public func subscribe<O: ObserverType>(_ observer: O) -> Disposable where O.Element == E {
        return subject.subscribe(observer)
    }
}

public extension BehaviorSubject {
    func asBehaviorObservable() -> BehaviorObservable<Element> {
        return BehaviorObservable(source: self)
    }
}

public extension BehaviorRelay {
    func asBehaviorObservable() -> BehaviorObservable<Element> {
        return BehaviorObservable(value: self.value, source: self.asObservable())
    }
}

public protocol OptionalType {
    associatedtype Wrapped
    func value() -> Wrapped?
}

extension Optional: OptionalType {
    public func value() -> Wrapped? {
        return self
    }
}

public extension ObservableType where Element: OptionalType {
    func filterSome() -> Observable<Element.Wrapped> {
        return self.flatMap { element -> Observable<Element.Wrapped> in
            if let value = element.value() {
                return Observable.just(value)
            } else {
                return Observable.empty()
            }
        }
    }
    
    func filterNone() -> Observable<Void> {
        return self.flatMap { element -> Observable<Void> in
            if element.value() == nil {
                return Observable.just(())
            } else {
                return Observable.empty()
            }
        }
    }
}

public extension ObservableType {
    func mapTo<R>(_ value: R) -> Observable<R> {
        return self.map { _ in value }
    }
}

public extension ObservableType where Element == Bool {
    func negate() -> Observable<Bool> {
        return self.map { !$0 }
    }
}

// withUnretained
public extension ObservableType where Element == Void {
    func withUnretained<Object: AnyObject>(_ unretained: Object) -> Observable<Object> {
        return flatMap { [weak unretained] element -> Observable<Object> in
            guard let obj = unretained else {
                return .empty()
            }
            return .just(obj)
        }
    }
}

// mapOptional
public extension ObservableType {
    func mapSome<R>(_ selector: @escaping (Self.Element) throws -> R?) -> Observable<R> {
        return self.map(selector).filter { $0 != nil }.map { $0! }
    }
}

// mapError
public extension ObservableType {
    func mapError(_ error: Error) -> Observable<Self.Element> {
        return self.catch { _ in
            Observable.error(error)
        }
    }
}

public extension ObservableType {
    func mapError(_ handler: @escaping (_ error: Error) -> Error) -> Observable<Self.Element> {
        return self.catch { error in
            Observable.error(handler(error))
        }
    }
}

// flatMapOptional
public extension ObservableType {
    func flatMapSome<R>(_ selector: @escaping (Element) throws -> Observable<R?>) -> Observable<R> {
        return self.flatMap { element -> Observable<R> in
            do {
                let result = try selector(element)
                return result.flatMap { element -> Observable<R> in
                    switch element {
                    case .some(let value):
                        return Observable<R>.just(value)
                    case .none:
                        return Observable<R>.empty()
                    }
                }
            } catch {
                return Observable<R>.error(error)
            }
        }
    }
}

// split
public extension ObservableType {
    func split(_ predicate: @escaping (Self.Element) throws -> Bool) -> (Observable<Self.Element>, Observable<Self.Element>) {
        let origin = self.share()
        return (origin.filter(predicate), origin.filter { try !predicate($0) })
    }
}

public extension ObservableType {
    // Useful for mapping an Observable<Whatever> into an Observable<Void> to hide details.
    func mapToVoid() -> Observable<Void> {
        return self.map { _ -> Void in
            return ()
        }
    }
    
    func mapToOptional() -> Observable<Element?> {
        return self.map { $0 }
    }
}

public extension ObserverType {
    func asNextObserver() -> AnyObserver<Element> {
        return AnyObserver { event in
            switch event {
            case .next(let value):
                self.onNext(value)
            case .error(let error):
                debugPrint("Supressed error asNextObserver: \(error)")
            case .completed:
                break
            }
        }
    }
}

public extension ObservableType {
    // Ensures that only one subscription to underlying observable is active at given time.
    // If subscription is made while subscription to underlying observable is active the
    // subscription will cause another subscription to underlying observable after previous
    // underlying observable has completed.
    func serializeAndShareSubscriptions(cancelHandler: @escaping ((Element) -> Bool) = { _ in return false }) -> Observable<Element> {
        var inProgress: Bool = false
        var pendingObservable: ConnectableObservable<Element>?
        
        func createUnderlyingObservable() -> ConnectableObservable<Element> {
            let onFinish: () -> Void = {
                if let pending = pendingObservable {
                    pendingObservable = nil
                    _ = pending.subscribe()
                    _ = pending.connect()
                } else {
                    inProgress = false
                }
            }
            return self.do(onError: { _ in onFinish() }, onCompleted: onFinish).publish()
        }
        
        return Observable<Element>.create { observer in
            let next = pendingObservable ?? createUnderlyingObservable()
            if !inProgress && pendingObservable == nil {
                inProgress = true
                DispatchQueue.main.async {
                    _ = next.subscribe()
                    _ = next.connect()
                }
            } else {
                pendingObservable = next
            }
            return next.doOnNext { result in
                if cancelHandler(result) {
                    // Empty the queue if cancelHandler returns true, i.e. syncing has been cancelled
                    pendingObservable = nil
                }
            }.subscribe(observer)
        }
    }
}

public extension ObservableType {
    func takeLatestFrom<O>(_ observable: O) -> Observable<O.Element> where O: ObservableConvertibleType {
        return self.withLatestFrom(observable) { $1 }
    }
    
    func combineLatestFrom<O>(_ observable: O) -> Observable<(Self.Element, O.Element)> where O: ObservableConvertibleType {
        return self.withLatestFrom(observable) { ($0, $1) }
    }
    
    func unwrap<T>() -> Observable<T> where Element == T? {
        return flatMap { Observable.from(optional: $0) }
    }
}

public extension ObservableType {
    func resendWhen<O>(_ observable: O) -> Observable<Element> where O: ObservableType {
        let trigger: Observable<Void> = observable.map { _ in }.startWith(())
        return Observable.combineLatest(self, trigger).map { ours, _ in ours }
    }
}

public extension ObservableType {
    func afterCompletionEmitInstead<O>(_ observable: O) -> Observable<O.Element> where O: ObservableConvertibleType {
        let ignored: Observable<O.Element> = self.takeLast(0).map { _ -> O.Element in fatalError() }
        return ignored.concat(observable)
    }
}

public extension ObservableType {
    static func justDeferred(_ block: @escaping () -> Element) -> Observable<Element> {
        return Observable.create { (observer: AnyObserver<Element>) -> Disposable in
            observer.onNext(block())
            observer.onCompleted()
            return Disposables.create()
        }
    }
}

public extension ObservableType {
    /**
     Passes latest and preceding elements
     - Parameter first: Initial previous value passed with the source sequence first item.
     */
    func withPrevious(startWith first: Element) -> Observable<(previous: Element, current: Element)> {
        return scan((first, first)) { ($0.1, $1) }
    }
    
    func withPrevious(startWith first: Element? = nil) -> Observable<(previous: Element?, current: Element)> {
        return scan((first, first)) { ($0.1, $1) }.map { ($0.0, $0.1!) }
    }
}

public extension ObservableType {
    func mapTo<R>(_ keyPath: KeyPath<Element, R>) -> Observable<R> {
        map { $0[keyPath: keyPath] }
    }
}
