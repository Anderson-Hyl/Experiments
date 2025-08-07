#if os(iOS)

import Foundation
import RxCocoa
import RxSwift
import UIKit

public extension Reactive where Base: UIApplication {
    var openURL: Binder<URL> {
        return Binder(base) { application, url in
            application.open(url)
        }
    }
}

#endif
