#if os(iOS)

import Foundation
import RxCocoa
import RxRelay
import RxSwift

public extension ObservableType {
    func bind<T>(to: OverrideRelay<T>) -> Disposable where Element == Observable<T> {
        return bind(to: to.subject)
    }
}

#endif
