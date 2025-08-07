#if os(iOS)

import Foundation
import RxCocoa
import RxSwift

/// Transforms input elements with a given transform operation (i.e. flatMap). In addition
/// provides a `Bool` sequence emitting `true` if transform operation is active (has been
/// invokes but has not yet emitted a value) and `false` otherwise.
///
/// Example use:
/// 1. user selects something in an UI
/// 2. the app starts loading data over network based on user selection, activity indicator is animating during the operation
/// 3. when the operation completes the UI is updated with the latest value, activity indicator stops animating and disappears
public class FlatMapLatestWithActive<Result> {
    /// A driver emitting transformed elements
    public let value: Driver<Result>
    
    /// A driver that emits `false` initially, then `true` every time a transform starts and `false` when transform ends.
    ///
    /// Useful to control an activity indicator.
    public let isActive: Driver<Bool>
    
    /// Initializes a sequence where each input element is transformed with provied transform function.
    ///
    /// - Parameters:
    ///   - input: A sequence of elements to be transformed.
    ///   - transform: A transform function to apply to each element.
    public init<Element>(input: Observable<Element>, transform: @escaping (Element) -> Single<Result>) {
        let phases = input
            .flatMapLatest { (inputValue) -> Observable<Phase<Result>> in
                return transform(inputValue).asPhases()
            }
            .share()
        self.value = phases.mapAsValue().asDriver(onErrorDriveWith: .empty())
        self.isActive = phases.mapAsIsActive().asDriver(onErrorJustReturn: false)
    }
    
    /// Initializes a sequence where each non-nil input element is transformed with provied transform function. An input with
    /// a `nil` value emits a `nil` output immediatelly without emitting `true` to `isActive` stream.
    ///
    /// This is useful for example when `input` presents a user selection where `nil` indicates "no selection" and results for
    /// empty selection are `nil` too.
    ///
    /// - Parameters:
    ///   - input: A sequence of elements to be transformed.
    ///   - transform: A transform function to apply to each non-nil element.
    public init<Element, R>(input: Observable<Element?>, transform: @escaping (Element) -> Single<Result>) where Result == R? {
        let phases = input
            .flatMapLatest { (inputValue) -> Observable<Phase<Result>> in
                guard let inputValue = inputValue else {
                    return .just(.completed(nil))
                }
                return transform(inputValue).asPhases()
            }
            .share()
        self.value = phases.mapAsValue().asDriver(onErrorJustReturn: nil)
        self.isActive = phases.mapAsIsActive().startWith(false).asDriver(onErrorJustReturn: false)
    }
}

public extension Observable {
    func flatMapLatestWithActive<R>(_ transform: @escaping (Element) -> Single<R>) -> FlatMapLatestWithActive<R> {
        return FlatMapLatestWithActive(input: self, transform: transform)
    }
    
    func flatMapLatestWithActive<T, R>(_ transform: @escaping (T) -> Single<R?>) -> FlatMapLatestWithActive<R?> where Element == T? {
        return FlatMapLatestWithActive(input: self, transform: transform)
    }
}

private enum Phase<T> {
    case started
    case completed(T)
    
    var value: T? {
        switch self {
        case .started:
            return nil
        case .completed(let value):
            return value
        }
    }
    
    var isActive: Bool {
        switch self {
        case .started:
            return true
        case .completed:
            return false
        }
    }
}

private extension PrimitiveSequence where Trait == SingleTrait {
    func asPhases() -> Observable<Phase<Element>> {
        return asObservable().map(Phase<Element>.completed).startWith(.started)
    }
}

private extension Observable {
    func mapAsValue<T>() -> Observable<T> where Element == Phase<T> {
        map { $0.value ?? nil }
            .filterSome()
    }
    
    func mapAsIsActive<T>() -> Observable<Bool> where Element == Phase<T> {
        return map { $0.isActive }
    }
}

#endif
