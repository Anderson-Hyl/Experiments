import Foundation

// NOTE: This file is included in UI test targets because the robot finds element via localized strings

/**
 How to use this function:
 
 Case 1: You have common key like "location.alert.content" and you want to use different values per app.
 
 "location.alert.content" = "Open settings and allow the app to access your location to track your route.";
 "location.alert.content.suunto" = "Open settings and allow Suunto app to access your location to track a workout.";
 
 In code, you should just use STLocalized("location.alert.content) without specifying app-variant.
 
 Case 2: You have key that you want to be "private" to one app (there is no common version)
 
 "suunto.routes.mc-notice.button.no" = "No";
 
 In code, you should include the app-variant as prefix, i.e. STLocalized("suunto.routes.mc-notice.button.no").
 */
public func STLocalized(_ key: String) -> String {
//    return localize(key, variant: AppConfiguration.shared.appVariant)
    key
}

/**
 A variant of the `STLocalized` function for fetching localized strings that are not yet final and should not be translated. Use this function for any text that is still under review or subject to change, and store it in the "NonFinalLocalizable.strings" file. This approach allows us to define keys for strings in advance.
 
 When the text is verified and finalized, move it to "Localizable.strings" and replace `STLocalizedNonFinal` with `STLocalized`.
 */
public func STLocalizedNonFinal(_ key: String) -> String {
    return localize(key, variant: AppConfiguration.shared.appVariant, tableName: "NonFinalLocalizable")
}

/**
 A variant of the `STLocalized` function specifically designed to fetch localized strings unique to and only used in the Suunto ZH version. Retrieves a localized string from the "ChinaLocalizable" strings file. Define localization keys and values in the "ChinaLocalizable.strings" file. This method will not retrieve localized strings from the "Localizable" strings file.
 */
public func STChinaLocalized(_ key: String) -> String {
    return localize(key, variant: AppConfiguration.shared.appVariant, tableName: "ChinaLocalizable")
}

/**
 Only used for apple watch
 */
public func STAWLocalized(_ key: String) -> String {
    let normalLocalization = NSLocalizedString(key, tableName: "WatchLocalizable", comment: "")
    if normalLocalization != key {
        return normalLocalization
    } else {
        return key
    }
}

// Only English strings are retrieved, for example, for sorting purposes
public func STEnglishLocalized(_ key: String) -> String {
    return localizeFromEnglishBundle(key)
}

public func STWatchLocalized(_ key: String) -> String {
    return localize(key, variant: AppConfiguration.shared.appVariant, tableName: "BESWatchLocalizable")
}

// Use this in the code to document if a string is not localized
public func STNotLocalized(_ notLocalized: NotLocalized) -> String {
    return notLocalized.displayText
}

public struct MissingLocalizationAnalytics: AnalyticsEvent {
    public let key: String
}

private func localize(_ key: String, variant: AppVariant, tableName: String? = nil) -> String {
    let localizationVariant: String = {
        switch variant {
        case .sportsTracker: return "sportstracker"
        case .suunto: return "suunto"
        case .suuntoChina: return "suunto"
        }
    }()
    
    let variantKey = "\(key).\(localizationVariant)"
    let variantLocalization = NSLocalizedString(variantKey, tableName: tableName, comment: "")
    if variantLocalization != variantKey {
        return variantLocalization
    }
    
    let normalLocalization = NSLocalizedString(key, tableName: tableName, comment: "")
    if normalLocalization != key {
        return normalLocalization
    }
    
#if !DEBUG
    AnalyticsService.shared.emit(MissingLocalizationAnalytics(key: key))
    debugPrint("Missing localization for \(key)")
#endif
    
    return localizeFromEnglishBundle(key, tableName: tableName)
}

private func localizeFromEnglishBundle(_ key: String, tableName: String? = nil) -> String {
    guard let path = Bundle.main.path(forResource: "en", ofType: "lproj"), let englishBundle = Bundle(path: path) else {
        return key
    }
    
    return NSLocalizedString(key, tableName: tableName, bundle: englishBundle, value: key, comment: "")
}
