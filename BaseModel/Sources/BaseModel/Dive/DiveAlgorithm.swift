import Base
import Foundation

public enum DiveAlgorithm: Equatable {
    case suuntoFusedRGBM2
    case suuntoFusedRGBM
    case suuntoTechnicalRGBM
    case suuntoRGBM
    case buhlmann
    case none
    // In case we cannot interpret the algorithm name
    case unknown(name: String)
    
    public var displayNameNotLocalized: String {
        switch self {
        case .suuntoFusedRGBM2: return "Suunto Fused™ RGBM 2"
        case .suuntoFusedRGBM: return "Suunto Fused™ RGBM"
        case .suuntoTechnicalRGBM: return "Suunto Technical RGBM"
        case .suuntoRGBM: return "Suunto RGBM"
        case .buhlmann: return "Bühlmann 16 GF"
        case .none: return "None"
        case .unknown(let name): return name
        }
    }
    
    public var displayNameLocalized: String {
        if self == .none {
            return STLocalized("suunto.dive-algorithm-none")
        }
        return displayNameNotLocalized
    }
}
