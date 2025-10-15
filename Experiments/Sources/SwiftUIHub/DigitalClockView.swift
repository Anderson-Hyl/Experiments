import SwiftUI

struct DigitalClockView: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1/60)) { context in
            
            // 获取所有时间分量（包含小数秒和毫秒，以便平滑移动）
            let components = Calendar.current.dateComponents([.hour, .minute, .second, .nanosecond], from: context.date)
            let fractionalSeconds = Double(components.second ?? 0) + Double(components.nanosecond ?? 0) / 1_000_000_000
            let fractionalMinutes = Double(components.minute ?? 0) + fractionalSeconds / 60.0
            // 转换为 12 小时制，并包含分钟的小数部分
            let fractionalHours = Double((components.hour ?? 0) % 12) + fractionalMinutes / 60.0
            
            // --- 角度计算 ---
            let secondsAngle = fractionalSeconds / 60 * 360 // 每秒 6 度
            let minutesAngle = fractionalMinutes / 60 * 360 // 每分钟 6 度
            let hoursAngle = fractionalHours / 12 * 360 // 每小时 30 度
            
            VStack {
                Text("Clock Animation")
                    .font(.headline)
                
                ZStack {
                    let size: CGFloat = 180 // 增加一点尺寸方便绘制刻度
                    
                    // 1. 表盘外圈
                    Circle()
                        .stroke(lineWidth: 2)
                        .frame(width: size, height: size)

                    // 2. 绘制刻度
                    TickMarks(size: size - 5)
                    
                    TickTextMarks(size: size - 30)
                    
                    // 3. 时针（新添加）
                    // 针体宽度 6，长度 40
                    Rectangle()
                        .fill(Color.primary.opacity(0.8))
                        .offset(y: -size * 0.4 / 2 / 2) // 长度的一半
                        .frame(width: 6, height: size * 0.4 / 2) // 时针相对较短
                        .rotationEffect(.degrees(hoursAngle))
                    
                    // 4. 分针 (基于你的代码，但使用平滑角度)
                    Rectangle()
                        .fill(Color.primary)
                        .offset(y: -size * 0.3 / 2) // 长度的一半
                        .frame(width: 4, height: size * 0.3)
                        .rotationEffect(.degrees(minutesAngle))
                    
                    // 5. 秒针 (基于你的代码，但使用平滑角度)
                    Rectangle()
                        .fill(Color.red)
                        .offset(y: -size * 0.45 / 2)
                        .frame(width: 2, height: size * 0.45) // 略长
                        .rotationEffect(.degrees(secondsAngle))

                    // 6. 中心点
                    Circle()
                        .fill(Color.primary)
                        .frame(width: 8, height: 8)
                }
                .padding(20) // 给刻度留出空间
            }
            .padding()
        }
    }
}

// 刻度绘制专用 View
struct TickMarks: View {
    let size: CGFloat
    
    var body: some View {
        // 绘制 60 个刻度，每 6 度一个
        ForEach(0..<60) { index in
            // 刻度类型：小时刻度 vs 分钟/秒刻度
            let isHourMark = index % 5 == 0 // 每隔 5 个刻度就是小时刻度 (0, 5, 10...)
            Rectangle()
            // 颜色：小时刻度更深，其他刻度较浅
                .fill(isHourMark ? Color.primary : Color.gray)
            // 宽度和高度：小时刻度更粗更长
                .frame(width: isHourMark ? 3 : 1.5,
                       height: 5)
            // 偏移：将其从中心点移动到圆周边缘
                .offset(y: -size / 2)
            // 旋转：将刻度旋转到正确的位置
                .rotationEffect(.degrees(Double(index) * 6))
            
        }
    }
}

struct TickTextMarks: View {
    let size: CGFloat
    let ticks = Array(stride(from: 0, to: 12, by: 3))
    var body: some View {
        ForEach(ticks, id: \.self) { index in
            Text("\(index)")
                .monospaced()
                .font(.caption)
                .offset(y: -size / 2)
                .bold()
                .rotationEffect(.degrees(Double(index) * 30))
        }
    }
}

#Preview {
    DigitalClockView()
}
