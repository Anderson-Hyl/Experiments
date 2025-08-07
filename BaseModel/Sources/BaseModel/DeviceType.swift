import Base
import Foundation

public enum DeviceType: String, CaseIterable {
    case ambit = "Ambit"
    case ambit2 = "Ambit2"
    case suuntoAmbit3Peak = "Ambit3"
    case suuntoAmbit3Run = "Ambit3R"
    case suuntoAmbit3Sport = "Ambit3S"
    case suuntoAmbit3Vertical = "Ambit3V"
    case suunto3Fitness = "3 Fitness"
    case suunto3G2 = "Suunto 3"
    case suunto5Peak = "Suunto 5 Peak"
    case suunto5 = "Suunto 5"
    case suunto7 = "Suunto 7"
    case suunto9 = "Suunto 9"
    case suunto9NoBaro = "Suunto 9."
    case suunto9Peak = "Suunto 9 Peak"
    case suunto9PeakPro = "Suunto 9 PeakPro"
    case spartanTrainer = "Spartan Trainer"
    case spartanUltra = "Spartan Ultra"
    case spartanSport = "Spartan Sport"
    case spartanSportWHR = "Spartan SportWHR"
    case spartanSportWHRB = "SpartanSportWHRB"
    case suuntoTraverse = "Traverse"
    case suuntoTraverseAlpha = "TraverseA"
    case suuntoEon = "EON Steel"
    case suuntoEonSteelBlack = "EON Steel Black"
    case suuntoEonCore = "EON Core"
    case salmon
    case dolphin = "Dolphin"
    case ruffe = "Suunto Ruffe"
    case sparrow = "Suunto Sparrow"
    case suuntoVertical = "Suunto Vertical"
    case orca = "Suunto Orca"
    case ocean = "Suunto Ocean"
    case seal = "Suunto Seal"
    case monkfish = "Suunto Race S"
    case race = "Suunto Race"
    case phoenix = "Suunto Phoenix"
    case suuntoD5 = "Suunto D5"
    case suuntoD4f = "Suunto D4f"
    case suuntoD4i = "Suunto D4i"
    case suuntoD4iNovo = "Suunto D4i Novo"
    case suuntoD6i = "Suunto D6i"
    case suuntoD6iNovo = "Suunto D6i Novo"
    case suuntoD6M = "Suunto D6M"
    case suuntoD9 = "Suunto D9"
    case suuntoD9tx = "Suunto D9tx"
    case suuntoDX = "Suunto DX"
    case vyperNovo = "Suunto Vyper Novo"
    case zoopNovo = "Suunto Zoop Novo"
    case suuntoCobra3 = "Suunto Cobra 3"
    case dilu = "Suunto Run"
    case sailfish = "Suunto Sailfish"
    case race2 = "Suunto Race 2"
    case suuntoGT = "Suunto GT"
    
    // The number of digits in the name is insufficient, and no space is added between the name and the number.
    // 名称位数不足，名称和数字中间没有添加空格
    case vertical2 = "Suunto Vertical2"
    
    // earPhone
    case earPhoneSU03 = "SU03"
    case earPhoneSU05 = "SU05"
    case earPhoneSU07 = "SU07"
    case earPhoneSU08 = "SU08"
    case earPhoneSU09 = "SU09"
    case earPhoneSU10 = "SU10"
    
    // External devices
    case karoo2 = "Karoo 2"
    
    case unknown = "Unknown"
    
    // Maps an alias device name to official device type:
    public static func deviceType(alias: String) -> DeviceType? {
        switch alias {
        case "Suunto Monkfish": return .monkfish
        default: return nil
        }
    }
    
    public func isWatchOrDiveComputer() -> Bool {
        !isEarphone()
    }
    
    public func isEarphone() -> Bool {
        switch self {
        case .earPhoneSU03,
             .earPhoneSU05,
             .earPhoneSU07,
             .earPhoneSU08,
             .earPhoneSU09,
             .earPhoneSU10:
            return true
        default:
            return false
        }
    }
    
    public func isOWSEarphone() -> Bool {
        switch self {
        case .earPhoneSU10:
            return true
        default:
            return false
        }
    }
    
    public func isExternalDevice() -> Bool {
        switch self {
        case .karoo2:
            return true
        default:
            return false
        }
    }
    
    public func isSpartan() -> Bool {
        return self != .unknown && !isLegacy() && !isDive() && !isSalmon() && !isExternalDevice() && !isEarphone()
    }
    
    public func isDolphin() -> Bool {
        switch self {
        case .dolphin, .suunto9Peak:
            return true
        default:
            return false
        }
    }
    
    public func isBESDevice() -> Bool {
        switch self {
        case .dilu:
            return true
        default:
            return false
        }
    }
    
    public func supportsOTA() -> Bool {
        switch self {
        case .dolphin,
             .suunto9Peak,
             .suunto9PeakPro,
             .ruffe,
             .suunto5Peak,
             .sparrow,
             .orca,
             .seal,
             .ocean,
             .monkfish,
             .phoenix,
             .race,
             .suuntoVertical,
             .dilu,
             .sailfish,
             .race2,
             .vertical2,
             .suuntoGT:
            return true
        // TODO: Remove default case
        default:
            return false
        }
    }
    
    public func isLegacy() -> Bool {
        switch self {
        case .suuntoAmbit3Peak, .suuntoAmbit3Run, .suuntoAmbit3Sport, .suuntoTraverse, .suuntoTraverseAlpha, .suuntoAmbit3Vertical:
            return true
        default:
            return false
        }
    }
    
    public func isLegacyOrDive() -> Bool {
        return isLegacy() || isEon() || self == .suuntoD5
    }
    
    public func isAmbit() -> Bool {
        switch self {
        case .suuntoAmbit3Peak, .suuntoAmbit3Run, .suuntoAmbit3Sport, .suuntoAmbit3Vertical:
            return true
        default:
            return false
        }
    }
    
    public func isTraverse() -> Bool {
        switch self {
        case .suuntoTraverse, .suuntoTraverseAlpha:
            return true
        default:
            return false
        }
    }
    
    /// Whether this is an EON family device. Use isDive() if you need to check whether the device is a dive computer or a sports watch.
    public func isEon() -> Bool {
        switch self {
        case .suuntoEon, .suuntoEonSteelBlack, .suuntoEonCore:
            return true
        default:
            return false
        }
    }
    
    public func isSalmon() -> Bool {
        return self == .salmon || self == .suunto7
    }
    
    public func isDive() -> Bool {
        switch self {
        case .suuntoEon,
             .suuntoEonSteelBlack,
             .suuntoEonCore,
             .suuntoD5,
             .suuntoD6iNovo,
             .suuntoCobra3,
             .suuntoD4f,
             .suuntoD4iNovo,
             .suuntoD4i,
             .suuntoD6i,
             .suuntoD6M,
             .suuntoD9,
             .suuntoD9tx,
             .suuntoDX,
             .vyperNovo,
             .zoopNovo:
            return true
        default:
            return false
        }
    }
    
    public func isNgDive() -> Bool {
        switch self {
        case .seal, .ocean, .suuntoGT:
            return true
        default:
            return false
        }
    }
    
    public func glonassAvailable() -> Bool {
        return isSpartan() || isTraverse() || self == .suuntoAmbit3Vertical
    }
    
    public var supportsSwUpdate: Bool {
        switch self {
        case .salmon, .suunto7:
            return false
        default:
            return true
        }
    }
    
    public var isAlwaysInSuuntoAppExclusiveMode: Bool {
        switch self {
        case .suuntoAmbit3Peak,
             .suuntoAmbit3Sport,
             .suuntoAmbit3Run,
             .suuntoAmbit3Vertical,
             .suuntoTraverse,
             .suuntoTraverseAlpha,
             .suunto3Fitness,
             .salmon,
             .suunto7,
             .suunto5,
             .suunto3G2,
             .dolphin,
             .suunto9Peak,
             .sparrow,
             .suunto9PeakPro:
            return true
        default:
            return false
        }
    }
    
    public var supportsGPSOptimization: Bool {
        switch self {
        case .suunto3Fitness, .suuntoEon, .suuntoEonSteelBlack, .suuntoEonCore, .suuntoD5, .suunto3G2, .suunto7, .salmon, .karoo2, .earPhoneSU03:
            return false
        default:
            return true
        }
    }
    
    public var coachAvailable: Bool {
        switch self {
        case .suunto3Fitness, .suunto5, .suunto3G2, .ruffe, .suunto5Peak:
            return true
        default:
            return false
        }
    }
    
    public func supportWaypointName() -> Bool {
        switch self {
        case .suunto5,
             .suunto7,
             .suunto9,
             .suunto9NoBaro,
             .suunto9Peak,
             .suunto9PeakPro,
             .salmon,
             .dolphin,
             .ruffe,
             .suunto5Peak,
             .sparrow,
             .orca,
             .phoenix,
             .race,
             .suuntoVertical,
             .seal,
             .ocean,
             .monkfish,
             .dilu,
             .sailfish,
             .race2,
             .vertical2,
             .suuntoGT:
            return true
        case .ambit,
             .ambit2,
             .spartanTrainer,
             .spartanUltra,
             .spartanSport,
             .spartanSportWHR,
             .spartanSportWHRB,
             .suunto3Fitness,
             .suunto3G2,
             .suuntoEon,
             .suuntoEonSteelBlack,
             .suuntoEonCore,
             .suuntoD5,
             .suuntoD6iNovo,
             .suuntoCobra3,
             .suuntoD4f,
             .suuntoD4iNovo,
             .suuntoD4i,
             .suuntoD6i,
             .suuntoD6M,
             .suuntoD9,
             .suuntoD9tx,
             .suuntoDX,
             .vyperNovo,
             .zoopNovo,
             .suuntoAmbit3Peak,
             .suuntoAmbit3Sport,
             .suuntoAmbit3Run,
             .suuntoAmbit3Vertical,
             .suuntoTraverse,
             .suuntoTraverseAlpha,
             .karoo2,
             .earPhoneSU03,
             .earPhoneSU05,
             .earPhoneSU07,
             .earPhoneSU08,
             .earPhoneSU09,
             .earPhoneSU10,
             .unknown:
            return false
        }
    }
    
    public var supportsMoments: Bool {
        switch self {
        case .suuntoAmbit3Vertical,
             .suuntoAmbit3Run,
             .suuntoAmbit3Sport,
             .suuntoAmbit3Peak,
             .suuntoTraverse,
             .suuntoTraverseAlpha,
             .spartanUltra,
             .spartanSport,
             .spartanTrainer,
             .spartanSportWHR,
             .spartanSportWHRB,
             .suunto3Fitness,
             .karoo2,
             .earPhoneSU03,
             .earPhoneSU05,
             .earPhoneSU07,
             .earPhoneSU08,
             .unknown:
            return false
        default:
            return true
        }
    }
    
    public func supportsPOIs() -> Bool {
        switch self {
        case .spartanUltra,
             .spartanSport,
             .spartanSportWHR,
             .spartanTrainer,
             .spartanSportWHRB,
             .suunto5,
             .suunto9,
             .suunto9NoBaro,
             .suunto9Peak,
             .suunto9PeakPro,
             .dolphin,
             .ruffe,
             .suunto5Peak,
             .sparrow,
             .orca,
             .phoenix,
             .race,
             .suuntoVertical,
             .seal,
             .ocean,
             .monkfish,
             .dilu,
             .sailfish,
             .race2,
             .vertical2,
             .suuntoGT:
            return true
        case .salmon,
             .suunto7,
             .ambit,
             .ambit2,
             .suunto3Fitness,
             .suunto3G2,
             .suuntoEon,
             .suuntoEonSteelBlack,
             .suuntoEonCore,
             .suuntoD5,
             .suuntoD6iNovo,
             .suuntoCobra3,
             .suuntoD4f,
             .suuntoD4iNovo,
             .suuntoD4i,
             .suuntoD6i,
             .suuntoD6M,
             .suuntoD9,
             .suuntoD9tx,
             .suuntoDX,
             .vyperNovo,
             .zoopNovo,
             .suuntoAmbit3Peak,
             .suuntoAmbit3Sport,
             .suuntoAmbit3Run,
             .suuntoAmbit3Vertical,
             .suuntoTraverse,
             .suuntoTraverseAlpha,
             .karoo2,
             .earPhoneSU03,
             .earPhoneSU05,
             .earPhoneSU07,
             .earPhoneSU08,
             .earPhoneSU09,
             .earPhoneSU10,
             .unknown:
            return false
        }
    }
    
    public var supportsGoals: Bool {
        switch self {
        case .ambit,
             .ambit2,
             .suuntoAmbit3Vertical,
             .suuntoAmbit3Run,
             .suuntoAmbit3Sport,
             .suuntoAmbit3Peak,
             .suuntoTraverse,
             .suuntoTraverseAlpha,
             .suuntoD5,
             .suuntoEon,
             .suuntoEonSteelBlack,
             .suuntoEonCore,
             .karoo2,
             .earPhoneSU03,
             .earPhoneSU05,
             .earPhoneSU07,
             .earPhoneSU08,
             .earPhoneSU09,
             .earPhoneSU10,
             .unknown:
            return false
        default:
            return true
        }
    }
    
    public var hardwareCompatibilityIdentifier: String {
        switch self {
        case .spartanTrainer:
            return "B"
        case .spartanUltra:
            return "A"
        case .spartanSport:
            return "A"
        case .spartanSportWHR:
            return "A"
        case .spartanSportWHRB:
            return "A"
        case .suunto3Fitness:
            return "E"
        case .suunto9:
            return "F"
        case .suunto9NoBaro:
            return "F"
        case .suunto5:
            return "J"
        case .suunto3G2:
            return "L"
        case .dolphin, .suunto9Peak:
            return "K"
        case .ruffe, .suunto5Peak:
            return "N"
        case .sparrow, .suunto9PeakPro:
            return "P"
        case .orca, .suuntoVertical:
            return "O"
        case .phoenix, .race:
            return "Q"
        case .seal, .ocean:
            return "M"
        case .monkfish:
            return "R"
        case .dilu:
            return "S"
        case .sailfish, .race2:
            return "U"
        case .suuntoGT:
            return "T"
        case .vertical2:
            return "V"
        default:
            return ""
        }
    }
    
    public var hardware: String {
        switch self {
        case .spartanTrainer:
            return "GP150"
        case .spartanUltra:
            return "1740G2"
        case .spartanSport:
            return "2451C1"
        case .spartanSportWHR:
            return "2795D4"
        case .spartanSportWHRB:
            return "3040D6"
        case .suunto3Fitness:
            return "SE650"
        case .suunto9:
            return "3835C1"
        case .suunto9NoBaro:
            return "4198C2"
        case .suunto5:
            return "GP180"
        case .suunto3G2:
            return "SE650_256"
        case .dolphin, .suunto9Peak:
            return "0508C1"
        case .sparrow, .suunto9PeakPro:
            return "1740G1"
        case .orca, .suuntoVertical:
            return "2773D4"
        case .phoenix, .race:
            return "0732A2"
        case .seal, .ocean:
            return "1740G1"
        case .monkfish:
            return "3509B1"
        case .dilu:
            return "0979D1"
        case .sailfish:
            #warning("TODO: Same to race, need to change")
            return "0732A2"
        case .race2:
            return "1310B2"
        case .suuntoGT:
            return "3272C2"
        case .vertical2:
            return "1251B1"
        default:
            return ""
        }
    }
    
    public var variant: String {
        switch self {
        case .ambit:
            return "Bluebird"
        case .ambit2:
            return "Duck"
        case .spartanTrainer:
            return "Forssa"
        case .spartanUltra:
            return "Amsterdam"
        case .spartanSport:
            return "Brighton"
        case .spartanSportWHR:
            return "Cairo"
        case .spartanSportWHRB:
            return "Gdansk"
        case .suunto3Fitness:
            return "Helsinki"
        case .suunto9:
            return "Ibiza"
        case .suunto9NoBaro:
            return "Lima"
        case .suunto5:
            return "Monza"
        case .suunto3G2:
            return "Oulu"
        case .salmon,
             .suunto7:
            return "Kyoto"
        case .suuntoAmbit3Peak:
            return "Emu"
        case .suuntoAmbit3Sport:
            return "Finch"
        case .suuntoAmbit3Run:
            return "Ibisbill"
        case .suuntoAmbit3Vertical:
            return "Kaka"
        case .suuntoTraverse:
            return "Jabiru"
        case .suuntoTraverseAlpha:
            return "Loon"
        case .suuntoEon:
            return "Guru"
        case .suuntoEonSteelBlack:
            return "GuruE"
        case .suuntoEonCore:
            return "Guru2"
        case .suuntoD5:
            return "Guru3"
        case .dolphin, .suunto9Peak:
            return "Nagano"
        case .suuntoD6iNovo:
            return "Suunto D6i Novo"
        case .suuntoCobra3:
            return "Suunto Cobra 3"
        case .suuntoD4f:
            return "Suunto D4f"
        case .suuntoD4iNovo:
            return "Suunto D4i Novo"
        case .suuntoD4i:
            return "Suunto D4i"
        case .suuntoD6i:
            return "Suunto D6i"
        case .suuntoD6M:
            return "Suunto D6M"
        case .suuntoD9:
            return "Suunto D9"
        case .suuntoD9tx:
            return "Suunto D9tx"
        case .suuntoDX:
            return "Suunto DX"
        case .vyperNovo:
            return "Suunto Vyper Novo"
        case .zoopNovo:
            return "Suunto Zoop Novo"
        case .ruffe, .suunto5Peak:
            return "Qingdao"
        case .sparrow, .suunto9PeakPro:
            return "Sapporo"
        case .suuntoVertical:
            return "Rostock"
        case .orca:
            return "Rostock"
        case .seal, .ocean:
            return "Porvoo"
        case .monkfish:
            return "Ulsan"
        case .karoo2:
            return "Karoo 2"
        case .phoenix, .race:
            return "Tianjin"
        case .dilu:
            return "Chengdu"
        case .vertical2:
            return "Xiamen"
        case .earPhoneSU03:
            return "SU03"
        case .earPhoneSU05:
            return "SU05"
        case .earPhoneSU07:
            return "SU07"
        case .earPhoneSU08:
            return "SU08"
        case .earPhoneSU09:
            return "SU09"
        case .earPhoneSU10:
            return "SU10"
        case .sailfish, .race2:
            return "Wismar"
        case .suuntoGT:
            return "Vaasa"
        case .unknown:
            return "unknown"
        }
    }
    
    public var hasIntroduction: Bool {
        switch self {
        case .suunto5,
             .suunto3Fitness,
             .suunto9,
             .suunto9NoBaro,
             .dolphin,
             .suuntoD5,
             .suuntoEonCore,
             .suuntoEon,
             .suuntoEonSteelBlack,
             .spartanTrainer,
             .spartanUltra,
             .spartanSport,
             .spartanSportWHR,
             .spartanSportWHRB,
             .salmon,
             .suunto7,
             .suunto3G2,
             .suunto9Peak,
             .ruffe,
             .suunto5Peak,
             .sparrow,
             .suunto9PeakPro,
             .earPhoneSU03,
             .orca,
             .phoenix,
             .race,
             .seal,
             .suuntoVertical,
             .vertical2,
             .ocean,
             .monkfish,
             .dilu,
             .earPhoneSU05,
             .earPhoneSU07,
             .earPhoneSU08,
             .earPhoneSU09,
             .earPhoneSU10,
             .sailfish,
             .race2:
            return true
        case .suuntoGT:
            #warning("Change this to true when introduction is implemented")
            return false
        case .ambit,
             .ambit2,
             .suuntoAmbit3Peak,
             .suuntoAmbit3Run,
             .suuntoAmbit3Sport,
             .suuntoAmbit3Vertical,
             .suuntoTraverse,
             .suuntoTraverseAlpha,
             .suuntoD4f,
             .suuntoD4i,
             .suuntoD4iNovo,
             .suuntoD6i,
             .suuntoD6iNovo,
             .suuntoD6M,
             .suuntoD9,
             .suuntoD9tx,
             .suuntoDX,
             .vyperNovo,
             .zoopNovo,
             .suuntoCobra3,
             .karoo2,
             .unknown:
            return false
        }
    }
    
    public var hasSportMode: Bool {
        switch self {
        case .ambit,
             .ambit2,
             .suuntoAmbit3Vertical,
             .suuntoAmbit3Run,
             .suuntoAmbit3Sport,
             .suuntoAmbit3Peak,
             .suuntoTraverse,
             .suuntoTraverseAlpha,
             .suuntoD5,
             .suuntoEon,
             .suuntoEonSteelBlack,
             .suuntoEonCore,
             .earPhoneSU03,
             .earPhoneSU05,
             .earPhoneSU07,
             .earPhoneSU08,
             .unknown:
            return false
        default:
            return true
        }
    }
    
    public var deviceUpdateURL: URL {
        let urlString: String = {
            switch self {
            case .spartanTrainer,
                 .spartanUltra,
                 .spartanSport,
                 .spartanSportWHR,
                 .spartanSportWHRB:
                return "https://www.suunto.com/Support/Software-updates/Release-notes/suunto-spartan-software-updates/"
            case .suunto3Fitness:
                return "https://www.suunto.com/Support/Software-updates/Release-notes/suunto-3-fitness/"
            case .suunto3G2:
                return "https://www.suunto.com/en-gb/Support/Software-updates/Release-notes/suunto-3/"
            case .suunto5:
                return "https://www.suunto.com/Support/Software-updates/Release-notes/suunto-5-software-updates/"
            case .suunto9,
                 .suunto9NoBaro:
                return "https://www.suunto.com/Support/Software-updates/Release-notes/suunto-9/"
            case .suunto9Peak:
                return "https://www.suunto.com/suunto9peak/userguide/softwareupdates"
            case .suunto5Peak:
                return "https://www.suunto.com/suunto5peak/userguide/softwareupdates"
            case .suunto9PeakPro, .sparrow:
                return "https://www.suunto.com/suunto9peakpro/userguide/softwareupdates"
            case .suuntoVertical, .orca:
                return "https://www.suunto.com/suuntovertical/userguide/softwareupdates"
            case .phoenix, .race:
                return "https://www.suunto.com/suuntorace/userguide/softwareupdates"
            case .seal, .ocean:
                return "https://www.suunto.com/suuntoocean/userguide/softwareupdates"
            case .monkfish:
                return "https://www.suunto.com/suuntoraces/userguide/softwareupdates"
            case .earPhoneSU03:
                return "https://www.suunto.com/suuntowing/userguide/softwareupdates"
            case .earPhoneSU05:
                return "https://www.suunto.com/suuntosonic/userguide/softwareupdates"
            case .earPhoneSU07:
                return "https://www.suunto.com/suuntoaqua/userguide/softwareupdates"
            case .earPhoneSU08:
                return "https://www.suunto.com/suuntoaqualight/userguide/softwareupdates"
            case .dilu:
                return "https://www.suunto.com/suuntorun/userguide/softwareupdates"
            case .sailfish, .race2, .vertical2:
                #warning("TODO: Need to change, it is default url now")
                return "https://www.suunto.com/software-updates/"
            case .suuntoGT:
                #warning("TODO: Need to change, it is default url now")
                return "https://www.suunto.com/software-updates/"
            case .ambit,
                 .ambit2,
                 .suuntoAmbit3Peak,
                 .suuntoAmbit3Run,
                 .suuntoAmbit3Sport,
                 .suuntoAmbit3Vertical,
                 .suuntoTraverse,
                 .suuntoTraverseAlpha,
                 .suuntoEon,
                 .suuntoEonSteelBlack,
                 .suuntoEonCore,
                 .suuntoD5,
                 .salmon,
                 .suunto7,
                 .unknown,
                 .dolphin,
                 .suuntoD6iNovo,
                 .suuntoCobra3,
                 .suuntoD4f,
                 .suuntoD4iNovo,
                 .suuntoD4i,
                 .suuntoD6i,
                 .suuntoD6M,
                 .suuntoD9,
                 .suuntoD9tx,
                 .suuntoDX,
                 .vyperNovo,
                 .zoopNovo,
                 .ruffe,
                 .karoo2,
                 .earPhoneSU09, // TODO: Add new url
                 .earPhoneSU10: // TODO: Add new url
                return "https://www.suunto.com/software-updates/"
            }
        }()
        return URL(string: urlString)!
    }
    
    public var hasUserGuide: Bool {
        return userGuideURL != nil
    }
    
    public var userGuideURL: URL? {
        let urlString: String? = {
            switch self {
            case .ambit: return
                "https://www.suunto.com/Support/sports-watches-support/suunto-ambit1/"
            case .ambit2: return
                "https://www.suunto.com/Support/sports-watches-support/suunto-ambit2-s/"
            case .spartanTrainer: return "https://www.suunto.com/Support/Product-support/suunto_spartan_trainer_wrist_hr/suunto_spartan_trainer_wrist_hr/"
            case .spartanUltra: return "https://www.suunto.com/Support/Product-support/suunto_spartan_ultra/suunto_spartan_ultra/"
            case .spartanSport: return "https://www.suunto.com/Support/Product-support/suunto_spartan_sport/suunto_spartan_sport/"
            case .spartanSportWHR: return "https://www.suunto.com/Support/Product-support/suunto_spartan_sport_wrist_hr/suunto_spartan_sport_wrist_hr/"
            case .spartanSportWHRB: return "https://www.suunto.com/Support/Product-support/suunto_spartan_sport_wrist_hr_baro/suunto_spartan_sport_wrist_hr_baro/"
            case .suunto3Fitness: return "https://www.suunto.com/Support/Product-support/suunto_3/suunto_3/"
            case .suunto9: return "https://www.suunto.com/Support/Product-support/suunto_9/suunto_9/"
            case .suunto9NoBaro: return "https://www.suunto.com/Support/Product-support/suunto_9/suunto_9/"
            case .suuntoAmbit3Peak: return "https://www.suunto.com/Support/Product-support/suunto_ambit3_peak/suunto_ambit3_peak/"
            case .suuntoAmbit3Run: return "https://ns.suunto.com/Manuals/Ambit3_Run/Userguides/Suunto_Ambit3_Run_UserGuide_EN.pdf?_ga=2.246224579.655734437.1557740369-1668644033.1557740369"
            case .suuntoAmbit3Sport: return "https://www.suunto.com/Support/Product-support/suunto_ambit3_sport/suunto_ambit3_sport/"
            case .suuntoAmbit3Vertical: return "https://www.suunto.com/Support/Product-support/suunto_ambit3_vertical/suunto_ambit3_vertical/"
            case .suuntoTraverse: return "https://www.suunto.com/Support/Product-support/suunto_traverse/suunto_traverse/"
            case .suuntoTraverseAlpha: return "https://www.suunto.com/Support/Product-support/suunto_traverse_alpha/suunto_traverse_alpha/"
            case .suuntoEon: return "https://www.suunto.com/Support/Product-support/suunto_eon_steel/suunto_eon_steel/"
            case .suuntoEonSteelBlack: return "https://www.suunto.com/suuntoeonsteelblack/userguide"
            case .suuntoEonCore: return "https://www.suunto.com/Support/Product-support/suunto_eon_core/suunto_eon_core/"
            case .suuntoD5: return "https://www.suunto.com/Support/Product-support/suunto_d5/suunto_d5/"
            case .salmon, .suunto7: return isChina ? "https://www.suunto.com/Suunto7UGcn" : "https://www.suunto.com/Suunto7UG"
            case .suunto5: return "https://www.suunto.com/Suunto5UG"
            case .suunto3G2: return "https://www.suunto.com/suunto_3/userguide"
            case .dolphin, .suunto9Peak: return "https://www.suunto.com/Support/Product-support/suunto_9_peak/suunto_9_peak/"
            case .ruffe, .suunto5Peak: return "https://www.suunto.com/Support/Product-support/suunto_5_peak/suunto_5_peak/"
            case .sparrow, .suunto9PeakPro: return "https://www.suunto.com/suunto9peakpro/userguide"
            case .orca, .suuntoVertical: return "https://www.suunto.com/suuntovertical/userguide"
            case .phoenix, .race: return "https://www.suunto.com/suuntorace/userguide"
            case .earPhoneSU03: return "https://www.suunto.com/suuntowing/userguide"
            case .earPhoneSU05: return "https://www.suunto.com/suuntosonic/userguide"
            case .earPhoneSU07: return "https://www.suunto.com/suuntoaqua/userguide"
            case .earPhoneSU08: return "https://www.suunto.com/suuntoaqualight/userguide"
            case .earPhoneSU09: return nil // TODO: add new user guide
            case .earPhoneSU10: return nil // TODO: add new user guide
            case .seal, .ocean: return "https://www.suunto.com/suuntoocean/userguide"
            case .monkfish: return "https://www.suunto.com/suuntoraces/userguide"
            case .dilu: return "https://www.suunto.com/suuntorun/userguide"
            case .sailfish, .race2, .vertical2:
                #warning("Need to add user guide url")
                return nil
            case .suuntoGT:
                #warning("Need to add user guide url")
                return nil
            case .karoo2: return nil
            case .unknown: return nil
            case .suuntoD6iNovo: return nil
            case .suuntoCobra3: return nil
            case .suuntoD4f: return nil
            case .suuntoD4iNovo: return nil
            case .suuntoD4i: return nil
            case .suuntoD6i: return nil
            case .suuntoD6M: return nil
            case .suuntoD9: return nil
            case .suuntoD9tx: return nil
            case .suuntoDX: return nil
            case .vyperNovo: return nil
            case .zoopNovo: return nil
            }
        }()
        return urlString.flatMap { URL(string: $0)! }
    }
    
    public var hasForceUpdateIntroduction: Bool {
        forceUpdateIntroductionUrl != nil
    }
    
    // Introduction to some highlights during force updates
    public var forceUpdateIntroductionUrl: URL? {
        let urlString: String? = {
            switch self {
            case .phoenix, .race:
                if isChina {
                    if AppConfiguration.backendConfigurationSelection == .test {
                        return "https://app.suunto-operations.cn/suuntorace/onboarding"
                    }
                    return "https://app.suunto.cn/suuntorace/onboarding"
                } else {
                    return "https://app.suunto.com/suuntorace/onboarding"
                }
            default:
                return nil
            }
        }()
        return urlString.flatMap { URL(string: $0)! }
    }
}

public extension DeviceType {
    init(deviceName: String) {
        // Check main device name:
        if let dt = DeviceType(rawValue: deviceName) { self = dt }
        // Check alias:
        else if let dt = Self.deviceType(alias: deviceName) { self = dt }
        else { self = .unknown }
    }
    
    init(officialProductName: String) {
        if let deviceType = DeviceType.allCases.first(where: { $0.officialProductName == officialProductName }) {
            self = deviceType
        } else {
            self = .unknown
        }
    }
    
    init(name: String) {
        if let deviceType = DeviceType.allCases.first(where: { name.starts(with: $0.variant) }) {
            self = deviceType
        } else if let deviceType = DeviceType.allCases.first(where: { $0.officialProductName.contains(name) }) {
            self = deviceType
        } else {
            self = .unknown
        }
    }
    
    var officialProductName: String {
        switch self {
        // Product name that should be used everywhere where it is visible to end user or sent to analytics
        // Product names are found from Confluence: https://amersportsdigital.atlassian.net/wiki/spaces/DES/pages/1046642705/SUUNTO+PRODUCT+NAMING
        case .ambit: return "Suunto Ambit"
        case .ambit2: return "Suunto Ambit2"
        case .spartanTrainer: return "Suunto Spartan Trainer"
        case .spartanUltra: return "Suunto Spartan Ultra"
        case .spartanSport: return "Suunto Spartan Sport"
        case .spartanSportWHR: return "Suunto Spartan Sport WHR"
        case .spartanSportWHRB: return "Suunto Spartan Sport WHR Baro"
        case .suuntoAmbit3Peak: return "Suunto Ambit3 Peak"
        case .suuntoAmbit3Sport: return "Suunto Ambit3 Sport"
        case .suuntoAmbit3Run: return "Suunto Ambit3 Run"
        case .suuntoAmbit3Vertical: return "Suunto Ambit3 Vertical"
        case .suuntoTraverse: return "Suunto Traverse"
        case .suuntoTraverseAlpha: return "Suunto Traverse Alpha"
        case .suuntoEon: return "Suunto EON Steel"
        case .suuntoEonSteelBlack: return "Suunto EON Steel Black"
        case .suuntoEonCore: return "Suunto EON Core"
        case .suuntoD5: return "Suunto D5"
        case .suunto3Fitness: return "Suunto 3 Fitness"
        case .suunto9: return "Suunto 9"
        case .suunto9NoBaro: return "Suunto 9"
        case .suunto7: return "Suunto 7"
        case .salmon: return "Suunto 7"
        case .suunto5: return "Suunto 5"
        case .suunto3G2: return "Suunto 3"
        case .dolphin: return "Suunto 9 Peak"
        case .suunto9Peak: return "Suunto 9 Peak"
        case .ruffe: return "Suunto 5 Peak"
        case .suunto5Peak: return "Suunto 5 Peak"
        case .sparrow: return "Suunto 9 Peak Pro"
        case .suunto9PeakPro: return "Suunto 9 Peak Pro"
        case .orca: return "Orca"
        case .seal: return "Suunto Ocean"
        case .ocean: return "Suunto Ocean"
        case .monkfish: return "Suunto Race S"
        case .phoenix, .race: return "Suunto Race"
        case .dilu: return "Suunto Run"
        case .sailfish: return "Suunto Sailfish"
        case .race2: return "Suunto Race 2"
        case .suuntoGT: return "Suunto GT"
        case .vertical2: return "Suunto Vertical 2"
        case .suuntoVertical: return "Suunto Vertical"
        case .suuntoD6iNovo: return "Suunto D6i Novo"
        case .suuntoCobra3: return "Suunto Cobra3"
        case .suuntoD4f: return "Suunto D4f"
        case .suuntoD4iNovo: return "Suunto D4i Novo"
        case .suuntoD4i: return "Suunto D4i"
        case .suuntoD6i: return "Suunto D6i"
        case .suuntoD6M: return "Suunto D6M"
        case .suuntoD9: return "Suunto D9"
        case .suuntoD9tx: return "Suunto D9tx"
        case .suuntoDX: return "Suunto DX"
        case .vyperNovo: return "Suunto Vyper Novo"
        case .zoopNovo: return "Suunto Zoop Novo"
        case .karoo2: return "Hammerhead Karoo 2"
        case .earPhoneSU03: return "Suunto Wing"
        case .earPhoneSU05: return "Suunto Sonic"
        case .earPhoneSU07: return "Suunto Aqua"
        case .earPhoneSU08: return "Suunto Aqua Light"
        case .earPhoneSU09: return "Suunto Wing 2"
        case .earPhoneSU10: return "OWS"
        case .unknown: return "Unknown"
        }
    }
    
    var augmentedUIScreenSizeCapability: String? {
        // TP #126082: Support SuuntoPlus app size reduction (screen size)
        switch self {
        case .suunto3G2,
             .suunto3Fitness,
             .suunto5,
             .suunto5Peak:
            return "ui_screensize_small"
        case .suunto9,
             .suunto9NoBaro,
             .suuntoVertical,
             .phoenix,
             .race,
             .orca,
             .seal,
             .ocean,
             .sailfish,
             .race2,
             .vertical2:
            return "ui_screensize_large"
        case .suunto9Peak:
            return "ui_screensize_medium"
        case .suuntoGT:
            #warning("Return correct value for SuuntoGT")
            return nil
        case .spartanUltra,
             .spartanSport,
             .spartanSportWHR,
             .spartanTrainer,
             .spartanSportWHRB,
             .dolphin,
             .ruffe,
             .sparrow,
             .suunto9PeakPro,
             .monkfish,
             .salmon,
             .suunto7,
             .ambit,
             .ambit2,
             .suuntoEon,
             .suuntoEonSteelBlack,
             .suuntoEonCore,
             .suuntoD5,
             .suuntoD6iNovo,
             .suuntoCobra3,
             .suuntoD4f,
             .suuntoD4iNovo,
             .suuntoD4i,
             .suuntoD6i,
             .suuntoD6M,
             .suuntoD9,
             .suuntoD9tx,
             .suuntoDX,
             .vyperNovo,
             .zoopNovo,
             .suuntoAmbit3Peak,
             .suuntoAmbit3Sport,
             .suuntoAmbit3Run,
             .suuntoAmbit3Vertical,
             .suuntoTraverse,
             .suuntoTraverseAlpha,
             .karoo2,
             .dilu,
             .earPhoneSU03,
             .earPhoneSU05,
             .earPhoneSU07,
             .earPhoneSU08,
             .earPhoneSU09,
             .earPhoneSU10,
             .unknown:
            return nil
        }
    }
    
    var analyticsName: String {
        switch self {
        case .suunto9:
            return "Suunto 9 Baro"
        default:
            return officialProductName
        }
    }
    
    var deviceIconName: String {
        switch self {
        case .suuntoEon, .suuntoEonSteelBlack, .suuntoEonCore:
            return "icon-eon-empty-small"
        case .karoo2:
            return "icon-karoo-2-empty-small"
        case .earPhoneSU03, .earPhoneSU05, .earPhoneSU07, .earPhoneSU08:
            return "icon-bone-earphone-small"
        default:
            return "icon-watch-empty-small"
        }
    }
    
    /// The image here has a cut-out effect for 3D video sharing
    var deviceLiteIconName: String {
        switch self {
        case .suuntoEon, .suuntoEonSteelBlack, .suuntoEonCore:
            return "icon-eon-empty-lite-small"
        case .karoo2:
            return "icon-karoo-2-empty-lite-small"
        case .earPhoneSU03, .earPhoneSU05, .earPhoneSU07, .earPhoneSU08:
            return "icon-bone-earphone-lite-small"
        default:
            return "icon-watch-empty-lite-small"
        }
    }
    
    var deviceBigIconName: String {
        switch self {
        case .suuntoEon, .suuntoEonSteelBlack, .suuntoEonCore:
            return "icon-eon-empty"
        default:
            return "icon-watch-empty"
        }
    }
    
    var deviceWidgetsIntroductionImageName: String {
        switch self {
        case .suuntoVertical, .orca, .vertical2:
            return "watch-widget-introduction-orca"
        case .suunto9PeakPro, .sparrow:
            return "watch-widget-introduction-sparrow"
        case .phoenix, .race, .sailfish, .race2:
            return "watch-widget-introduction-phoenix"
        case .seal, .ocean:
            return "watch-widget-introduction-seal"
        case .monkfish:
            return "watch-widget-introduction-monkfish"
        case .dilu:
            return "watch-widget-introduction-dilu"
        default:
            return ""
        }
    }
    
    var deviceWidgetsIntroductionText: String {
        switch self {
        case .dilu:
            return STLocalized("watch-widget-introduction-dilu-text")
        default:
            return STLocalized("watch-widget-introduction-text")
        }
    }
    
    var isPublic: Bool {
        switch self {
        // NOTE: Add devices that are not public yet here
        case .dolphin,
             .ruffe,
             .salmon,
             .sparrow,
             .orca,
             .seal,
             .phoenix,
             .sailfish,
             .race2,
             .vertical2,
             .suuntoGT,
             .earPhoneSU05,
             .earPhoneSU08,
             .earPhoneSU09,
             .earPhoneSU10:
            return false
        case .ambit,
             .ambit2,
             .suuntoAmbit3Peak,
             .suuntoAmbit3Run,
             .suuntoAmbit3Sport,
             .suuntoAmbit3Vertical,
             .suunto3Fitness,
             .suunto3G2,
             .suunto5Peak,
             .suunto5,
             .suunto7,
             .suunto9,
             .suunto9NoBaro,
             .suunto9Peak,
             .suunto9PeakPro,
             .spartanTrainer,
             .spartanUltra,
             .spartanSport,
             .spartanSportWHR,
             .spartanSportWHRB,
             .suuntoTraverse,
             .suuntoTraverseAlpha,
             .suuntoEon,
             .suuntoEonSteelBlack,
             .suuntoEonCore,
             .suuntoVertical,
             .ocean,
             .monkfish,
             .race,
             .suuntoD5,
             .suuntoD4f,
             .suuntoD4i,
             .suuntoD4iNovo,
             .suuntoD6i,
             .suuntoD6iNovo,
             .suuntoD6M,
             .suuntoD9,
             .suuntoD9tx,
             .suuntoDX,
             .vyperNovo,
             .zoopNovo,
             .suuntoCobra3,
             .dilu,
             .earPhoneSU03,
             .earPhoneSU07,
             .karoo2,
             .unknown:
            return true
        }
    }
}
