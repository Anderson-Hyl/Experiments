import SwiftUI

struct TaskSegment: Identifiable {
    let id = UUID()
    let name: String
    let startAngle: Double // degrees, 0–360
    let endAngle: Double   // degrees, 0–360
    let color: Color
}

let segments: [TaskSegment] = [
    .init(name: "Meeting",  startAngle: 0,   endAngle: 60,  color: .blue),
    .init(name: "Building", startAngle: 90,  endAngle: 120, color: .yellow),
    .init(name: "Lunch",    startAngle: 140, endAngle: 150, color: .green),
    .init(name: "Working",  startAngle: 200, endAngle: 270, color: .red),
    .init(name: "Creative", startAngle: 320, endAngle: 350, color: .purple)
]

struct TaskArcShape: Shape {
    let startAngle: Angle
    let endAngle: Angle
    let innerRadius: CGFloat
    let outerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var path = Path()
        path.addArc(center: center,
                    radius: outerRadius,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: false)
        path.addArc(center: center,
                    radius: innerRadius,
                    startAngle: endAngle,
                    endAngle: startAngle,
                    clockwise: true)
        path.closeSubpath()
        return path
    }
}

struct ArcChartView: View {
    let segments: [TaskSegment]
    let innerRadius: CGFloat
    let outerRadius: CGFloat
    var body: some View {
        ZStack {
            ForEach(segments) { segment in
                TaskArcShape(
                    startAngle: .degrees(segment.startAngle - 90),
                    endAngle: .degrees(segment.endAngle - 90),
                    innerRadius: innerRadius,
                    outerRadius: outerRadius
                )
                .fill(segment.color.opacity(0.4))
                .overlay(
                    TaskArcShape(
                        startAngle: .degrees(segment.startAngle - 90),
                        endAngle: .degrees(segment.endAngle - 90),
                        innerRadius: innerRadius,
                        outerRadius: outerRadius
                    )
                    .stroke(segment.color.opacity(0.8), lineWidth: 1.5)
                )
                .contextMenu {
                    Button("Delete", systemImage: "trash") {
                        print(segment.name)
                    }
                    .tint(.red)
                }
            }
        }
    }
}

#Preview {
    ArcChartView(segments: segments, innerRadius: 80, outerRadius: 120)
        .padding()
}
