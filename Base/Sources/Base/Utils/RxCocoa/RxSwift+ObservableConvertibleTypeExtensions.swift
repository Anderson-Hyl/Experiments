#if os(iOS)

import Foundation
import RxCocoa
import RxSwift

public extension ObservableConvertibleType {
    /**
     Converts observable sequence of `Result<T, E>` objects to `Driver` trait. Errors will be passed `.failure(error)` items.
     - returns: Driver trait.
     */
    func asDriver<T>() -> RxCocoa.Driver<Self.Element> where Self.Element == Result<T, Error> {
        asDriver { error -> Driver<Result<T, Error>> in
            .just(.failure(error))
        }
    }
}

#endif
