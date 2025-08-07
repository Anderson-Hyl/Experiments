import Foundation

public extension Constants.Authentication {
    static let keychainAccessGroup = AppConfiguration.shared.appVariant.isChina == true ? "2U4JC2Z3MS.com.sports-tracker.china.shared.keychain" : "LE9Y6XTR5H.com.sports-tracker.shared.keychain"
    
    enum KeychainKeys {
        public static let sessionKey = "st2-session-key"
        public static let totpTimeOffset = "st2-totpTimeOffset"
    }
}
