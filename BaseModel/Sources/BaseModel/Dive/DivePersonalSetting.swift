import Base
import Foundation

public enum DivePersonalSetting: Int, CaseIterable, Codable {
    case veryAggressive = -2
    case aggressive = -1
    case normal = 0
    case conservative = 1
    case veryConservative = 2
    
    public var stringValue: String {
        let prefix = (self.rawValue > 0) ? "+" : ""
        return prefix + String(self.rawValue)
    }
}
