#if os(iOS)

import RxCocoa
import RxSwift
import UIKit

public class UIRxTapGestureRecognizer: UITapGestureRecognizer {
    public let subject: PublishSubject<Void>
    
    public init(subject: PublishSubject<Void>) {
        self.subject = subject
        super.init(target: nil, action: nil)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        subject.onNext(())
    }
}

public protocol TappableViewTrait: AnyObject {
    var isTappingEnabled: Bool { get }
    var rx_tap: ControlEvent<Void> { get }
}

public extension TappableViewTrait where Self: UIView {
    var isTappingEnabled: Bool {
        return true
    }
    
    var rx_tap: ControlEvent<Void> {
        let tapGestureRecognizer = addTapGestureRecognizerIfNeeded()
        let tapEvents = tapGestureRecognizer.subject
            .asObservable()
            .filter { [weak self] _ in
                return self?.isTappingEnabled ?? false
            }
        
        return ControlEvent(events: tapEvents)
    }
    
    private func addTapGestureRecognizerIfNeeded() -> UIRxTapGestureRecognizer {
        if let firstTapGestureRecognizer = gestureRecognizers?.first(where: { $0 is UIRxTapGestureRecognizer }) as? UIRxTapGestureRecognizer {
            return firstTapGestureRecognizer
        }
        
        let tapSubject = PublishSubject<Void>()
        let tapGestureRecognizer = UIRxTapGestureRecognizer(subject: tapSubject)
        
        isUserInteractionEnabled = true
        addGestureRecognizer(tapGestureRecognizer)
        
        return tapGestureRecognizer
    }
}

#endif
