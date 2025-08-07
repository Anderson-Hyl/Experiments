#if os(iOS)

import Foundation
import RxCocoa
import RxSwift
import UIKit

public extension UIView {
    /**
     Bindable sink for `userInteractionEnabled` property.
     */
    var rx_userInteractionEnabled: AnyObserver<Bool> {
        return AnyObserver { [weak self] event in
            MainScheduler.ensureExecutingOnScheduler()
            
            switch event {
            case .next(let value):
                self?.isUserInteractionEnabled = value
            case .error(let error):
                let error = "Binding error to UI: \(error)"
#if DEBUG
                print(error)
#endif
            case .completed:
                break
            }
        }
    }
    
    class func rx_animate(withDuration duration: TimeInterval, delay: TimeInterval = 0, options: UIView.AnimationOptions = [], animations: @escaping () -> Swift.Void) -> Observable<Bool> {
        return Observable.create { observer in
            UIView.animate(withDuration: duration, delay: delay, options: options, animations: animations) { finished in
                observer.onNext(finished)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    class func rx_animate(withDuration duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping: CGFloat, initialSpringVelocity: CGFloat, options: UIView.AnimationOptions, animations: @escaping () -> Void) -> Observable<Bool> {
        return Observable.create { observer in
            UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: usingSpringWithDamping, initialSpringVelocity: initialSpringVelocity, options: options, animations: animations) { finished in
                observer.onNext(finished)
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
}

public extension UIViewController {
    var rx_viewControllerDidBecomeActive: Observable<Void> {
        return NotificationCenter.default.rx.notification(UIApplication.didBecomeActiveNotification, object: nil)
            .filter { [weak self] _ in
                guard let strongSelf = self else { return false }
                let trackingViewVisible = (strongSelf.isViewLoaded && strongSelf.view.window != nil)
                return trackingViewVisible
            }
            .map { _ in return () }
    }
    
    var rx_viewControllerWillResignActivity: Observable<Void> {
        return NotificationCenter.default.rx.notification(UIApplication.willResignActiveNotification, object: nil)
            .filter { [weak self] _ in
                guard let strongSelf = self else { return false }
                let trackingViewVisible = (strongSelf.isViewLoaded && strongSelf.view.window != nil)
                return trackingViewVisible
            }
            .map { _ in return () }
    }
    
    var rx_viewControllerWillEnterForeground: Observable<Void> {
        return NotificationCenter.default.rx.notification(UIApplication.willEnterForegroundNotification, object: nil)
            .filter { [weak self] _ in
                guard let strongSelf = self else { return false }
                let trackingViewVisible = (strongSelf.isViewLoaded && strongSelf.view.window != nil)
                return trackingViewVisible
            }
            .map { _ in return () }
    }
}

public extension UIViewController {
    var rx_keyboardWillShow: Observable<Notification> {
        return NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    var rx_keyboardDidShow: Observable<Notification> {
        return NotificationCenter.default.rx.notification(UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    var rx_keyboardWillHide: Observable<Notification> {
        return NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification, object: nil)
    }
}

public extension Reactive where Base: UIViewController {
    private func controlEvent(for selector: Selector) -> ControlEvent<Void> {
        return ControlEvent(events: sentMessage(selector).map { _ in })
    }
    
    var viewDidLoad: ControlEvent<Void> {
        return controlEvent(for: #selector(UIViewController.viewDidLoad))
    }
    
    var viewWillAppear: ControlEvent<Void> {
        return controlEvent(for: #selector(UIViewController.viewWillAppear))
    }
    
    var viewDidAppear: ControlEvent<Void> {
        return controlEvent(for: #selector(UIViewController.viewDidAppear))
    }
    
    var viewWillDisappear: ControlEvent<Void> {
        return controlEvent(for: #selector(UIViewController.viewWillDisappear))
    }
    
    var viewDidDisappear: ControlEvent<Void> {
        return controlEvent(for: #selector(UIViewController.viewDidDisappear))
    }
    
    var viewSafeAreaInsetsDidChange: ControlEvent<Void> {
        return controlEvent(for: #selector(UIViewController.viewSafeAreaInsetsDidChange))
    }
    
    var isViewVisible: Observable<Bool> {
        let visibilityChange: Observable<Bool> = Observable.merge(
            viewDidAppear.asObservable().map { true },
            viewDidDisappear.asObservable().map { false }
        )
        let initialVisibility: Observable<Bool> = Observable.justDeferred { [weak base] in
            guard let controller = base else {
                return false
            }
            return controller.isViewLoaded && controller.view.window != nil
        }
        return initialVisibility.concat(visibilityChange).distinctUntilChanged()
    }
    
    func dismiss(animated: Bool, completion: (() -> Void)? = nil) -> Binder<Void> {
        return Binder<Void>(base) { (controller: UIViewController, _) in
            controller.dismiss(animated: animated, completion: completion)
        }
    }
}

public extension UIButton {
    var rx_image: AnyObserver<UIImage?> {
        return AnyObserver { [weak self] event in
            MainScheduler.ensureExecutingOnScheduler()
            
            switch event {
            case .next(let value):
                self?.setImage(value, for: .normal)
            case .error(let error):
                let error = "Binding error to UI: \(error)"
#if DEBUG
                print(error)
#endif
            case .completed:
                break
            }
        }
    }
}

public extension UINavigationItem {
    var rx_title: AnyObserver<String?> {
        return AnyObserver { [weak self] event in
            MainScheduler.ensureExecutingOnScheduler()
            
            switch event {
            case .next(let value):
                self?.title = value
            case .error(let error):
                let error = "Binding error to UI: \(error)"
#if DEBUG
                print(error)
#endif
            case .completed:
                break
            }
        }
    }
}

public extension SharedSequence where Element: OptionalType {
    func filterSome() -> SharedSequence<SharingStrategy, Element.Wrapped> {
        return self.flatMap { element -> SharedSequence<SharingStrategy, Element.Wrapped> in
            if let value = element.value() {
                return SharedSequence<SharingStrategy, Element.Wrapped>.just(value)
            } else {
                return SharedSequence<SharingStrategy, Element.Wrapped>.empty()
            }
        }
    }
    
    func filterNone() -> SharedSequence<SharingStrategy, Void> {
        return self.flatMap { element -> SharedSequence<SharingStrategy, Void> in
            if element.value() == nil {
                return SharedSequence<SharingStrategy, Void>.just(())
            } else {
                return SharedSequence<SharingStrategy, Void>.empty()
            }
        }
    }
}

public extension PrimitiveSequenceType where Trait == SingleTrait {
//    func logCompletionTime(_ title: String) -> Single<Element> {
//        return Single.deferred { () -> PrimitiveSequence<SingleTrait, Element> in
//            let before = Date()
//            return self.do(onSuccess: { _ in
//                let after = Date()
//                let timeInterval = after.timeIntervalSince(before)
//                let durationString = String(format: "%.0f ms", timeInterval)
//                let message = "\(title) completion time: \(durationString)"
//                DebugLogService.shared.log(type: "completionTime-" + title, message: message)
//            })
//        }
//    }
    
    func mapCompletionTime() -> Single<(Element, TimeInterval, Date)> {
        return Single.deferred { () -> PrimitiveSequence<SingleTrait, (Element, TimeInterval, Date)> in
            let before = Date()
            return self.map { element in
                let after = Date()
                let timeInterval = after.timeIntervalSince(before)
                return (element, timeInterval, after)
            }
        }
    }
}

public extension Reactive where Base: UIView {
    /// Bindable sink for `alpha` property that animates
    func alpha(withDuration: TimeInterval) -> Binder<CGFloat> {
        return Binder(self.base) { view, alpha in
            guard view.alpha != alpha else { return }
            UIView.animate(withDuration: withDuration, animations: {
                view.alpha = alpha
            })
        }
    }
    
    var isHiddenValue: ControlEvent<Bool> {
        let events = base.rx.observe(Bool.self, #keyPath(UIView.isHidden)).filterSome()
        return ControlEvent(events: events)
    }
}

public extension Reactive where Base: UILabel {
    var textChanged: Driver<Void> {
        observe(\.text).mapToVoid().asDriver { _ in .just(()) }
    }
}

public extension Reactive where Base: UINavigationItem {
    var rightBarButtonItemsEnabled: Binder<Bool> {
        Binder(base) { navigationItem, isEnabled in
            navigationItem.rightBarButtonItems?.forEach {
                $0.isEnabled = isEnabled
            }
        }
    }
    
    var leftBarButtonItemsEnabled: Binder<Bool> {
        Binder(base) { navigationItem, isEnabled in
            navigationItem.leftBarButtonItems?.forEach {
                $0.isEnabled = isEnabled
            }
        }
    }
}

public extension SharedSequenceConvertibleType where Element == Bool, SharingStrategy == DriverSharingStrategy {
    func negate() -> SharedSequence<DriverSharingStrategy, Bool> {
        return self.map { !$0 }
    }
}

#endif
