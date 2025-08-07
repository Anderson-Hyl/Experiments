import Foundation
import Charts
import SwiftUI

struct WeekdayScore: Identifiable {
    let id = UUID()
    let day: String         // 如 "Mon", "Tue", ...
    let value: Double       // 如 70.0
}

let sampleData: [WeekdayScore] = [
    .init(day: "Mon", value: 70),
    .init(day: "Tue", value: 68),
    .init(day: "Wed", value: 72),
    .init(day: "Thu", value: 60),
    .init(day: "Fri", value: 65),
    .init(day: "Sat", value: 85),
//    .init(day: "Sun", value: 0) // 没数据
]

let chartsColors: [Color] = [
    Color(red: 33/255, green: 206/255, blue: 86/255),
    Color(red: 156/255, green: 225/255, blue: 87/255),
    Color(red: 239/255, green: 183/255, blue: 73/255),
    Color(red: 255/255, green: 124/255, blue: 59/255),
    Color(red: 219/255, green: 49/255, blue: 90/255)
]


struct RecoveryStateCharts: View {
    @State private var data = sampleData
    var body: some View {
        Chart(data) { dayScore in
            RectangleMark(
                yStart: .value("WeekDay", 0),
                yEnd: .value("Score", 100)
            )
            .foregroundStyle(.linearGradient(stops: [
                .init(color: Color(red: 33/255, green: 206/255, blue: 86/255), location: 0.0),   // y = 100
                .init(color: Color(red: 156/255, green: 225/255, blue: 87/255), location: 0.2),  // y = 80
                .init(color: Color(red: 239/255, green: 183/255, blue: 73/255), location: 0.4),  // y = 60
                .init(color: Color(red: 255/255, green: 124/255, blue: 59/255), location: 0.6),  // y = 40
                .init(color: Color(red: 219/255, green: 49/255, blue: 90/255), location: 0.8),   // y = 20
                .init(color: Color(red: 219/255, green: 49/255, blue: 90/255), location: 1.0),   // y = 0
            ], startPoint: .top, endPoint: .bottom))
            .mask {
                LineMark(
                    x: .value("WeekDay", dayScore.day),
                    y: .value("Score", dayScore.value)
                )
                .symbol(Circle().strokeBorder(lineWidth: 2))
                .symbolSize(64)
                .foregroundStyle(dayScore.value >= 70 ? Color.green : Color.yellow)
            }
        }
        .chartOverlay { proxy in
            HStack {
                VStack(spacing: 1) {
                    ForEach(chartsColors, id: \.self) { color in
                        Rectangle()
                            .fill(color)
                            .frame(width: 4, height: (proxy.plotSize.height - 4) / 5)
                            .offset(y: -11)
                    }
                }
                Spacer()
            }
        }
        .chartYScale(domain: 0...100)
        .chartYAxis {
            AxisMarks(values: .stride(by: 20)) { value in
                AxisGridLine(stroke: value.index == 0 ?  StrokeStyle(lineWidth: 1) : StrokeStyle(lineWidth: 1, dash: [2]))
                    .foregroundStyle(value.index == 0 ? Color(.systemGray) : Color(.systemGray4))
                AxisValueLabel()
            }
        }
        .chartXAxis {
            AxisMarks(position: .bottom) {
                AxisTick(length: 4, stroke: StrokeStyle(lineWidth: 1))
                    .foregroundStyle(.gray)
                AxisValueLabel()
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .padding()
    }
}

#Preview {
    RecoveryStateCharts()
}
