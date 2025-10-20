import SwiftUI

extension Int {
  public var swiftUIColor: Color {
    get {
      Color(hex: self)
    }
    set {
      guard let components = UIColor(newValue).cgColor.components
      else { return }
      let r = Int(components[0] * 0xFF) << 24
      let g = Int(components[1] * 0xFF) << 16
      let b = Int(components[2] * 0xFF) << 8
      let a = Int((components.indices.contains(3) ? components[3] : 1) * 0xFF)
      self = r | g | b | a
    }
  }
}

public extension Color {
    
    /// 使用整数 Hex（例如 0xFFCC00）和可选 alpha 初始化 Color
    init(hex: Int, alpha: Double = 1.0) {
        let red = Double((hex >> 16) & 0xFF) / 255.0
        let green = Double((hex >> 8) & 0xFF) / 255.0
        let blue = Double(hex & 0xFF) / 255.0
        
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }

    /// 使用字符串（例如 "#FFCC00", "FFCC00", "#FFCC00AA"）初始化 Color
    init?(hexString: String) {
        var hex = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        // 去掉前导 #
        if hex.hasPrefix("#") {
            hex.removeFirst()
        }
        
        // 支持 RGB (6位) 或 RGBA (8位)
        guard hex.count == 6 || hex.count == 8 else {
            return nil
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgbValue)
        
        let red = Double((rgbValue >> (hex.count == 8 ? 24 : 16)) & 0xFF) / 255.0
        let green = Double((rgbValue >> (hex.count == 8 ? 16 : 8)) & 0xFF) / 255.0
        let blue = Double((rgbValue >> (hex.count == 8 ? 8 : 0)) & 0xFF) / 255.0
        let alpha = Double(hex.count == 8 ? (rgbValue & 0xFF) : 255) / 255.0
        
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
    
    static var random: Color {
        // Generate random values for red, green, and blue components.
        // The values are in the range of 0.0 to 1.0.
        let red = Double.random(in: 0...1)
        let green = Double.random(in: 0...1)
        let blue = Double.random(in: 0...1)
        
        // Generate a random value for opacity.
        let opacity = Double.random(in: 0.8...1) // Opacity is slightly higher to ensure visibility.
        
        return Color(red: red, green: green, blue: blue, opacity: opacity)
    }
}
