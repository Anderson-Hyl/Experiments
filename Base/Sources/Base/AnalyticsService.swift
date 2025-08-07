import Foundation
import RxSwift

/// Service to act as an "event bus" for abstract analytics data.
///
/// The idea is that analytics data does not necessarily go directly
/// to Amplitude, but there can be additional aggregation happening
/// inside the application. Only the aggregated analytics data will
/// be sent to downstream services.
///
/// This concept allows moving say button press counters or error counters
/// that exist solely for analytics purposes out of the main program flow.
///
/// Using a types to represent analytics events breaks compile
/// time dependencies which in a more rigid setup could cause massive
/// recompilation even for tiny change in analytics related code.
public class AnalyticsService {
    public init() {}
    public static let shared: AnalyticsService = AnalyticsService()
    
    private var registrationMap: [AnyHashable: [AnalyticsEventRegistration]] = [:]
    
    /// Send an abstract analytics event through this "event bus"
    public func emit<T: AnalyticsEvent>(_ event: T) {
        DispatchQueue.analyticsQueue.async { [weak self] in
            guard let self = self else { return }
            if let registrations = self.registrationMap[key(type: T.self)] {
                for registration in registrations {
                    registration.handle(event)
                }
            }
        }
    }
    
    /// Handling of abstract analytics events is registered with this function.
    public func observe<T: AnalyticsEvent>(_ keyType: T.Type) -> Observable<T> {
        return Observable
            .create { (observer: AnyObserver<AnalyticsEvent>) -> Disposable in
                
                let keyHashable = key(type: keyType)
                let registration = AnalyticsEventRegistration(keyHashable, observer)
                
                self.register(registration)
                
                return Disposables.create { [weak self] in
                    self?.unregister(registration)
                }
            }
            .map { $0 as! T }
    }
    
    private func register(_ registration: AnalyticsEventRegistration) {
        DispatchQueue.analyticsQueue.sync { [weak self] in
            self?.registerSync(registration)
        }
    }
    
    private func registerSync(_ registration: AnalyticsEventRegistration) {
        if var previouslyCreatedArray = registrationMap[registration.key] {
            previouslyCreatedArray.append(registration)
            registrationMap[registration.key] = previouslyCreatedArray
        } else {
            let array: [AnalyticsEventRegistration] = [registration]
            registrationMap[registration.key] = array
        }
    }
    
    private func unregister(_ registration: AnalyticsEventRegistration) {
        DispatchQueue.analyticsQueue.async { [weak self] in
            self?.unregisterSync(registration)
        }
    }
    
    private func unregisterSync(_ registration: AnalyticsEventRegistration) {
        if let previouslyCreatedArray = registrationMap[registration.key] {
            registrationMap[registration.key] = previouslyCreatedArray.filter { $0 !== registration }
        }
    }
}

private func key<T: AnalyticsEvent>(type: T.Type) -> AnyHashable {
    return AnyHashable(InternalKey<T>())
}

private struct InternalKey<T: AnalyticsEvent>: Hashable {
    private let type: String
    
    init() {
        self.type = "\(T.self)"
    }
}

private class AnalyticsEventRegistration {
    private let observer: AnyObserver<AnalyticsEvent>
    let key: AnyHashable
    
    init(_ key: AnyHashable, _ observer: AnyObserver<AnalyticsEvent>) {
        self.key = key
        self.observer = observer
    }
    
    func handle(_ event: AnalyticsEvent) {
        observer.on(.next(event))
    }
}
