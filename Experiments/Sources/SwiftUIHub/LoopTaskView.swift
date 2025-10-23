import SwiftUI

struct ClockView: View {
    let tickMarks: [TickMark]
    var body: some View {
        ClockDialView(tickMarks: tickMarks, tasks: segments)
            .frame(maxWidth: 320, maxHeight: 320)
            .aspectRatio(1, contentMode: .fit)
    }
}

struct ClockDialView: View {
    let tickMarks: [TickMark]
    let tasks: [TaskSegment]
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Circle()
                    .stroke(Color.clear, lineWidth: 1)
                ClockTickMarksView(size: proxy.size.width, ticks: tickMarks)
                ClockTickTextMarksView(size: proxy.size.width - 60, ticks: Array(stride(from: 0, to: 24, by: 3)), unitDegree: 360 / 24)
                ArcChartView(segments: segments, innerRadius: proxy.size.width / 2 - 60, outerRadius: proxy.size.width / 2)
            }
        }
    }
}

struct ClockTickMarksView: View {
    let size: CGFloat
    let ticks: [TickMark]
    var body: some View {
        ForEach(ticks) { tick in
            let style = tick.type.style
            Rectangle()
                .fill(Color.primary.opacity(style.opacity))
                .frame(width: style.width, height: style.height)
                .offset(y: -(size / 2) + style.height / 2)
                .rotationEffect(.degrees(tick.angle))
        }
    }
}

struct ClockTickTextMarksView: View {
    let size: CGFloat
    let ticks: [Int]
    let unitDegree: Double
    var body: some View {
        ForEach(ticks, id: \.self) { tick in
            ZStack {
                Text("\(tick)")
                    .monospaced()
                    .font(.footnote)
                    .bold()
                    .rotationEffect(.degrees(-Double(tick) * unitDegree))
            }
            .offset(y: -size / 2)
            .rotationEffect(.degrees(Double(tick) * unitDegree))
        }
    }
}


struct AdaptiveTaskWatchContainer: View {
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var taskCount: Int = 10
    let tickMarks: [TickMark] = TickMarkConfiguration.standard.generateTicks()

    #if os(iOS)
    let isPhone: Bool = UIDevice.current.userInterfaceIdiom == .phone
    #else
    let isPhone: Bool = false
    #endif
    
    var isCompact: Bool {
        #if os(iOS)
        return isPhone || horizontalSizeClass == .compact
        #else
        return false
        #endif
    }
    
    var body: some View {
        if isCompact {
            // MARK: - 紧凑布局 (iPhone 模式): TabView 横向滑动
            compactLayout
        } else {
            // MARK: - 常规布局 (iPad/macOS 模式): LazyVGrid 表格展示
            regularLayout
        }
    }
    
    // MARK: - 布局容器定义
    
    var compactLayout: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) { // Use LazyHStack for efficiency and page alignment
                ForEach(0..<taskCount, id: \.self) { index in
                    ClockView(tickMarks: TickMarkConfiguration.standard.generateTicks())
                        .containerRelativeFrame(.horizontal) // Each page takes full screen width
                        .tag(index)
                        
                }
                
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .scrollIndicators(.hidden)
    }

    
    // iPad/macOS 布局：使用 LazyVGrid 实现自适应表格
    var regularLayout: some View {
        // 使用 LazyVGrid 让系统根据可用宽度自动排列列数
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 250), spacing: 20)], spacing: 20) {
                ForEach(0..<taskCount, id: \.self) { index in
                    ClockView(tickMarks: tickMarks)
                }
            }
            .padding()
        }
    }
}

// 3. 预览示例
#Preview {
    AdaptiveTaskWatchContainer()
        .frame(width: 800, height: 600)
}
