import SwiftUI

struct CircleWaveView: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1/30)) { ctx in
            ZStack {
                WavesView(size: 180, t: ctx.date.timeIntervalSinceReferenceDate)
                Circle()
                    .stroke(.primary, lineWidth: 1)
                    .frame(width: 180, height: 180)
            }
        }
    }
}

struct WavesView: View {
    let size: CGFloat
    let t: TimeInterval

    var body: some View {
        ForEach(0..<60, id: \.self) { index in
            let base: CGFloat = 10
            let max:  CGFloat = 30
            // 用正弦生成“稳定”的高度（不再每帧随机）
            let speed = 2.0                   // 速度（越大越快）
            let phase = Double(index) * .pi/8 // 每根柱的相位差
            let v = (sin(t * speed + phase) + 1) * 0.5 // 0...1
            let height = base + CGFloat(v) * (max - base)

            Rectangle()
                .fill(.primary)
                .frame(width: 2, height: height)
                .offset(y: -(size / 2) - height / 2) // ✅ 底部贴在圆周
                .rotationEffect(.degrees(Double(index) * 6))
                .animation(.snappy, value: height)
        }
    }
}

#Preview {
    CircleWaveView()
}
