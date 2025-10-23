import SwiftUI

struct ArcShape: Shape {
    var startAngle: Angle
    var endAngle: Angle
    var clockwise: Bool = false // 默认逆时针（iOS 默认坐标系）

    func path(in rect: CGRect) -> Path {
        // 确定中心点和半径
        let center = CGPoint(x: rect.midX, y: rect.midY)
        // 半径取矩形尺寸中较小者的一半
        let radius = min(rect.width, rect.height) / 2
        
        var path = Path()
        
        // 使用 addArc 绘制弧线
        // 注意：SwiftUI 的 Angle 0 度位于右侧 (3点钟方向)。
        // 并且默认是以逆时针方向增加角度 (clockwise: false)。
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: clockwise // false: 逆时针；true: 顺时针
        )
        
        return path
    }
}

struct KnobView: View {
    var body: some View {
        ZStack {
            
        }
    }
}

#Preview {
    KnobView()
}
