import Foundation

// NOTE: global properties to determine app variant at runtime
// Currently in SPM packages build time flags cannot be mapped to custom Xcode configurations so app variant can only be determined at runtime
public let isSuuntoApp = AppConfiguration.shared.appVariant.isSuuntoApp
public let isSportsTracker = AppConfiguration.shared.appVariant.isSportsTracker
public let isChina = AppConfiguration.shared.appVariant.isChina
public let isSuuntoGlobal = AppConfiguration.shared.appVariant.isSuuntoGlobal
public var isiOSAppOnMac: Bool {
    if #available(iOS 14.0, *), #available(watchOS 7.0, *) {
        // This could be switched to isMacCatalystApp which would handle catalyst too.
        return ProcessInfo.processInfo.isiOSAppOnMac
    } else {
        return false
    }
}

public var isDebugBuild: Bool {
#if DEBUG
    return true
#else
    return false
#endif
}

public enum AppVariant: String {
    case sportsTracker = "SportsTracker"
    case suunto = "Suunto"
    case suuntoChina = "SuuntoChina"
}

extension AppVariant {
    var isSuuntoApp: Bool {
        switch self {
        case .suunto, .suuntoChina: return true
        default: return false
        }
    }
    
    var isSuuntoGlobal: Bool {
        switch self {
        case .suunto: return true
        default: return false
        }
    }
    
    var isSportsTracker: Bool {
        switch self {
        case .sportsTracker: return true
        default: return false
        }
    }
    
    var isChina: Bool {
        switch self {
        case .suuntoChina: return true
        default: return false
        }
    }
    
    public var appGroup: String {
        switch self {
        case .sportsTracker, .suunto: return "group.com.sports-tracker.iphone.shared"
        case .suuntoChina: return "group.com.sports-tracker.iphone.china"
        }
    }
}

/// Used to debug the application against different backends
public enum AppConfigurationBackend: String, CaseIterable {
    case byBuild
    case debug
    case test
    case production
    /// For use with simulator and locally running Asko backend
    case localhost
}

/// Used to debug Helpshift
public enum AppConfigurationHelpshift {
    case byBuild
    case test
}

public enum EndpointVersion: String {
    case version1 = "v1"
    case version2 = "v2"
}

private let backendConfigurationSelectionKey = "backendConfigurationSelection"
private let isHelpShiftTestInstanceInUseKey = "isHelpShiftTestInstanceInUse"

/// Application wide configuration values.
/// Some of these values are hard coded and some come from .plist files.
public struct AppConfiguration {
    public let appVariant: AppVariant
    public let chatbotURL: String?
    public let reviewLink: String
    public let remoteConfigurationEndpoint: String
    public let heatMapEndpoint: String
    public let apiEndPoint: String
    let dailyAPIEndPoint: String
    public let proOpenWeatherEndPoint: String
    public let generalOpenWeatherEndPoint: String
    public let wechatSportsEndPoint: String
    public let combineOpenWeatherEndPoint: String
    public let webRoot: String
    public let movescountLoginEndPoint: String
    public let movescountAPIEndPoint: String
    public let analyticsEndPoint: String
    public let webShareRoot: String
    public let activityWebShareRoot: String
    public let supportMail: String
    public let supportContactForm: String
    public let amplitudeApiKey: String
    public let appSidePulseTrackApiKey: String
    public let watchSidePulseTrackApiKey: String
    public let helpshiftApiKey: String
    public let helpshiftDomainName: String
    public let helpshiftAppId: String
    public let networkApiBrand: String
    public let gaPropertyId: String
    public let gaPropertyIdTestflight: String
    public let inAppUrlPrefix: [String]
    public let webBasedPolicyAndTerms: Bool
    public let updatedTermsURL: URL
    public let signupTermsURL: URL
    public let privacyPolicyURL: URL
    public let serviceTermsURL: URL
    public let dataPracticesURL: URL
    public let dbFileBaseName: String
    public let tileServerURL: String
    public let wxOpenSDKAppId: String
    public let chinaOpenSDKUniversalLink: String
    public let xhsAppId: String
    public let douyinAppId: String
    public let weiboAppId: String
    public let devicesEndpoint: String
    public let appWebViewEndPoint: String
    public let amapAppKey: String
    public let marketingApiEndPoint: String
    
    // Only for Suunto
    public let sportmodeComponentURL: String
    public let sportmodeTestComponentURL: String
    public let watchOfflineMapsOSMDisclaimerURL: URL
    public let earphoneURL: String
    public let assetsURL: String
    
    public let pastActivitySettingEndpoint: String
    
    public func apiEndPoint(version: EndpointVersion) -> String {
        self.apiEndPoint + version.rawValue
    }
    
    public func dailyAPIEndPoint(version: EndpointVersion) -> String {
        self.dailyAPIEndPoint + version.rawValue
    }
}

extension AppConfiguration {
    public func hasStringValidUrlPrefix(str: String) -> Bool {
        return inAppUrlPrefix.first(where: { str.starts(with: $0) }) != nil
    }
}

extension AppConfiguration {
    public static var shared: AppConfiguration = {
        let (appVariant, buildVariant) = getAppVariantAndBuildVariant()
        let helpshiftMode = isHelpShiftTestInstanceInUse ? AppConfigurationHelpshift.test : AppConfigurationHelpshift.byBuild
        return AppConfiguration(backendMode: backendConfigurationSelection, helpshiftMode: helpshiftMode, appVariant: appVariant, buildVariant: buildVariant)
    }()
    
    public static func configureEarlyDuringAppDidFinishLaunching(_ variant: AppVariant) {
        // Actually we just ensure loading the configuration and checking that configured AppVariant matches dynamic one
        guard AppConfiguration.shared.appVariant == variant else {
            fatalError("Invalid app configuration")
        }
    }
    
    public static var isHelpShiftTestInstanceInUse: Bool {
        return UserDefaults.standard.bool(forKey: isHelpShiftTestInstanceInUseKey)
    }
    
    public static func setHelpShiftTestInstanceInUse(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: isHelpShiftTestInstanceInUseKey)
    }
    
    public static var backendConfigurationSelection: AppConfigurationBackend {
        if let backendConfigurationSelection = UserDefaults.standard.value(forKey: backendConfigurationSelectionKey) as? String,
            let parsed = AppConfigurationBackend(rawValue: backendConfigurationSelection) {
            return parsed
        }
        
        return AppConfigurationBackend.byBuild // safe default
    }
    
    public static func setBackendConfigurationSelection(_ value: AppConfigurationBackend) {
        UserDefaults.standard.set(value.rawValue, forKey: backendConfigurationSelectionKey)
    }
    
    // MARK: Private
    
    private init(backendMode: AppConfigurationBackend = .byBuild,
                 helpshiftMode: AppConfigurationHelpshift = .byBuild,
                 appVariant: AppVariant,
                 buildVariant: BuildVariant) {
        // Unfortunately, Suunto and SuuntoChina share the same config file.
        let configurationAppVariant: AppVariant = appVariant == .suuntoChina ? .suunto : appVariant
        
        let interpretedBuildVariant = backendMode.buildVariant ?? buildVariant
        let interpretedConfigurationDictionary = ConfigurationReader(appVariant: configurationAppVariant, buildVariant: interpretedBuildVariant).configurations
        let endpointType: String = appVariant.isChina ? "cn" : "global"
        
        // Start initializing configuration values:
        self.appVariant = appVariant
        self.reviewLink = "itms-apps://itunes.apple.com/us/app/ST/id426684873?action=write-review"
        
        self.appWebViewEndPoint = interpretedConfigurationDictionary.getEndpoint("AppWebViewEndPoint", type: endpointType)
        self.remoteConfigurationEndpoint = interpretedConfigurationDictionary.getEndpoint("RemoteConfigurationEndpoint", type: endpointType)
        self.heatMapEndpoint = interpretedConfigurationDictionary.getEndpoint("HeatmapRoot", type: endpointType)
        self.proOpenWeatherEndPoint = "https://pro.openweathermap.org/data/2.5"
        self.generalOpenWeatherEndPoint = "http://api.openweathermap.org/data/2.5"
        self.wechatSportsEndPoint = interpretedConfigurationDictionary.getEndpoint("WechatSportsEndPoint", type: endpointType)
        
        self.devicesEndpoint = interpretedConfigurationDictionary.getEndpoint("DevicesEndpoint", type: endpointType)
        self.pastActivitySettingEndpoint = interpretedConfigurationDictionary.getEndpoint("PastActivitySettingEndpoint", type: endpointType)
        
        switch backendMode {
        case .byBuild:
            self.dbFileBaseName = "db" // The default behavior is just to use the same db regardless of build type
            self.apiEndPoint = interpretedConfigurationDictionary.getEndpoint("STAPIEndPoint", type: endpointType)
        case .localhost:
            self.dbFileBaseName = "db_dev_localhost_backend" // dedicated db to allow the developer to keep login
            self.apiEndPoint = "http://localhost:8080/apiserver/"
        default: // rest of AppConfigurationBackend modes go by whatever is in the .plist files for the same key
            self.dbFileBaseName = "db_dev_\(backendMode.rawValue)_backend" // dedicated dbs to allow the developer to keep login
            self.apiEndPoint = interpretedConfigurationDictionary.getEndpoint("STAPIEndPoint", type: endpointType)
        }
        
        if appVariant.isSuuntoApp {
            self.dailyAPIEndPoint = interpretedConfigurationDictionary.getEndpoint("247APIEndpoint", type: endpointType)
            self.combineOpenWeatherEndPoint = interpretedConfigurationDictionary.getEndpoint("CombineOpenWeatherEndPoint", type: endpointType)
            self.analyticsEndPoint = interpretedConfigurationDictionary.getEndpoint("AnalyticsEndpoint", type: endpointType)
            self.watchSidePulseTrackApiKey = interpretedConfigurationDictionary["WatchSidePulseTrackApiKey"] as! String
        } else {
            self.dailyAPIEndPoint = ""
            self.combineOpenWeatherEndPoint = "https://weather-test.sports-tracker.com"
            self.analyticsEndPoint = ""
            self.watchSidePulseTrackApiKey = ""
        }
        
        self.tileServerURL = interpretedConfigurationDictionary.getEndpoint("TileServer", type: endpointType)
        
        self.webRoot = interpretedConfigurationDictionary["WebRoot"] as! String
        
        self.movescountLoginEndPoint = interpretedConfigurationDictionary["MCLoginEndPoint"] as! String
        
        self.movescountAPIEndPoint = interpretedConfigurationDictionary.getEndpoint("MCAPIEndPoint", type: endpointType)
        self.webShareRoot = interpretedConfigurationDictionary.getEndpoint("WebShareRoot", type: endpointType)
        self.activityWebShareRoot = interpretedConfigurationDictionary.getEndpoint("ActivityWebShareRoot", type: endpointType)
        
        self.supportMail = interpretedConfigurationDictionary["SupportMail"] as! String
        self.chatbotURL = interpretedConfigurationDictionary["ChatbotURL"] as? String
        self.supportContactForm = interpretedConfigurationDictionary["SupportContactForm"] as! String
        self.amplitudeApiKey = interpretedConfigurationDictionary["AmplitudeApiKey"] as! String
        self.appSidePulseTrackApiKey = interpretedConfigurationDictionary["AppSidePulseTrackApiKey"] as! String
        self.helpshiftDomainName = interpretedConfigurationDictionary["HelpshiftDomainName"] as! String
        
        switch helpshiftMode {
        case .byBuild:
            self.helpshiftApiKey = interpretedConfigurationDictionary["HelpshiftApiKey"] as! String
            self.helpshiftAppId = interpretedConfigurationDictionary["HelpshiftAppId"] as! String
        case .test:
            self.helpshiftApiKey = "a2d5d96d644756cd5e66a51cd451f497"
            self.helpshiftAppId = "sports-tracker_platform_20190109125745107-9f6034f8b20479d"
        }
        
        self.networkApiBrand = interpretedConfigurationDictionary["NetworkApiBrand"] as! String
        
        self.gaPropertyId = interpretedConfigurationDictionary["GAPropertyId"] as! String
        
        self.gaPropertyIdTestflight = interpretedConfigurationDictionary["GAPropertyIdTestflight"] as! String
        
        self.inAppUrlPrefix = interpretedConfigurationDictionary["InAppUrlPrefix"] as! [String]
        
        self.sportmodeComponentURL = interpretedConfigurationDictionary.getEndpoint("SportmodeComponentURL", type: endpointType)
        self.sportmodeTestComponentURL = interpretedConfigurationDictionary.getEndpoint("TestSportmodeComponentURL", type: endpointType)
        
        if appVariant == .suuntoChina {
            self.webBasedPolicyAndTerms = false
        } else {
            self.webBasedPolicyAndTerms = true
        }
        
        let communityHost = interpretedConfigurationDictionary.getEndpoint("CommunityHost", type: endpointType)
        self.updatedTermsURL = URL(string: "\(communityHost)/update")!
        self.signupTermsURL = URL(string: communityHost)!
        self.privacyPolicyURL = URL(string: "\(communityHost)/privacy-policy")!
        self.serviceTermsURL = URL(string: "\(communityHost)/service-terms")!
        self.dataPracticesURL = URL(string: "\(communityHost)/read-more")!
        
        self.earphoneURL = interpretedConfigurationDictionary.getEndpoint("EarphoneURL", type: endpointType)
        self.assetsURL = interpretedConfigurationDictionary.getEndpoint("AssetsURL", type: endpointType)
        self.watchOfflineMapsOSMDisclaimerURL = URL(string: "https://www.suunto.com/support/disclaimers/offline-maps")!
        
        if appVariant == .suuntoChina {
            self.wxOpenSDKAppId = interpretedConfigurationDictionary["WXOpenSDKAppId"] as! String
            self.chinaOpenSDKUniversalLink = interpretedConfigurationDictionary["ChinaOpenSDKUniversalLink"] as! String
            self.weiboAppId = interpretedConfigurationDictionary["WeiboAppId"] as! String
            self.xhsAppId = interpretedConfigurationDictionary["XHSAppId"] as! String
            self.douyinAppId = interpretedConfigurationDictionary["DouyinAppId"] as! String
            self.amapAppKey = interpretedConfigurationDictionary["AmapAppKey"] as! String
        } else {
            self.wxOpenSDKAppId = ""
            self.chinaOpenSDKUniversalLink = ""
            self.weiboAppId = ""
            self.xhsAppId = ""
            self.douyinAppId = ""
            self.amapAppKey = ""
        }
        
        self.marketingApiEndPoint = apiEndPoint.replacingOccurrences(of: "/apiserver/", with: "/marketing/api")
    }
}

private func getAppVariantAndBuildVariant() -> (AppVariant, BuildVariant) {
    guard let infoDictionary = Bundle.main.infoDictionary else {
        fatalError("No info dictionary available")
    }
    
    guard let targetConfiguration = infoDictionary["Configuration"] as? String else {
        fatalError("Missing 'Configuration' in info dictionary")
    }
    
    let components = targetConfiguration.split(separator: "-")
    
    // Configuration values in the `Info.plist` files contain the app variant
    // and build variant, for example "SportsTracker-Release".
    guard components.count == 2,
        let appVariant = AppVariant(rawValue: String(components[0])),
        let buildVariant = BuildVariant(rawValue: String(components[1]))
    else {
        fatalError("Wrong format for 'Configuration', got \(targetConfiguration)")
    }
    
    return (appVariant, buildVariant)
}

/// Extracts the correct sub dictionaries from the 2 configuration .plist files.
private class ConfigurationReader {
    public let configurations: [String: Any]
    
    init(appVariant: AppVariant, buildVariant: BuildVariant) {
        let appConfiguration = "\(appVariant.rawValue)Configurations"
        
        guard let commonConfigurations = readSubConfig(resourceName: "CommonConfigurations", buildVariant),
            let configurations = readSubConfig(resourceName: appConfiguration, buildVariant) else {
            fatalError("Could not read configuration for appVariant: \(appVariant) buildVariant: \(buildVariant)")
        }
        let dictionary = NSMutableDictionary()
        dictionary.addEntries(from: commonConfigurations as! [AnyHashable: Any])
        dictionary.addEntries(from: configurations as! [AnyHashable: Any])
        self.configurations = dictionary as! [String: Any]
    }
}

/// Helper function for ConfigurationReader
private func readSubConfig(resourceName: String, _ buildVariant: BuildVariant) -> NSDictionary? {
    if let configPath: String = Bundle.main.path(forResource: resourceName, ofType: "plist"),
        let configDictionary = NSDictionary(contentsOfFile: configPath),
        let subConfigurations = configDictionary[buildVariant.rawValue] as? NSDictionary {
        return subConfigurations
    } else {
        return nil
    }
}

/// Enumeration of the possible sub keys in the configuration .plist files
private enum BuildVariant: String {
    case test = "Test"
    case debug = "Debug"
    case release = "Release"
}

private extension AppConfigurationBackend {
    /// For some backend configuration modes, there is a matching configuration block in the .plist files
    /// which we can use to get the correct backend url.
    var buildVariant: BuildVariant? {
        switch self {
        case .production: return BuildVariant.release
        case .debug: return BuildVariant.debug
        case .test: return BuildVariant.test
        default: return nil
        }
    }
}

private extension Dictionary where Key == String {
    func getEndpoint(_ key: String, type: String) -> String {
        var endpoint: String?
        // First check if there is only global endpoint (no Dictionary, just String)?
        if let global = self[key] as? String { endpoint = global }
        else if let dict = self[key] as? Dictionary, let specifiedEndpoint = dict[type] as? String {
            endpoint = specifiedEndpoint
        }
        let result = endpoint ?? ""
        print("### \(key): \(result)")
        return result
    }
}
