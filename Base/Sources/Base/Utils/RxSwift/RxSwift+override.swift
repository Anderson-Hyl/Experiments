import Foundation
import RxSwift
public extension Observable {
    func override(source: Observable<Observable<Element>>) -> Observable<Element> {
        return source
            .map { Observable.concat($0, self) }
            .startWith(self)
            .switchLatest()
    }
    
    func override(source: OverrideRelay<Element>) -> Observable<Element> {
        return override(source: source.overrides)
    }
}

public class OverrideRelay<T> {
    public let subject = PublishSubject<Observable<T>>()
    
    public var overrides: Observable<Observable<T>> {
        return subject.asObservable()
    }
    
    public func override(source: Observable<T>) {
        subject.onNext(source)
    }
    
    public init() {}
}
