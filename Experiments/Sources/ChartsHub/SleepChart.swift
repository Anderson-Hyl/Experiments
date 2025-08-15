import Charts
import SwiftUI

struct SleepStats: Identifiable {
    let day: String  // e.g. "Mon"
    let sleepDuration: TimeInterval  // 单位：秒
    let avgHeartRate: Int  // 单位：bpm

    var id: String {
        day
    }
}

let mockSleepStats: [SleepStats] = [
    .init(day: "Mon", sleepDuration: 2.5 * 3600, avgHeartRate: 78),
    .init(day: "Tue", sleepDuration: 7.0 * 3600, avgHeartRate: 80),
    .init(day: "Wed", sleepDuration: 8.5 * 3600, avgHeartRate: 85),
    .init(day: "Thu", sleepDuration: 5.5 * 3600, avgHeartRate: 78),
    .init(day: "Fri", sleepDuration: 7.0 * 3600, avgHeartRate: 81),
    .init(day: "Sat", sleepDuration: 4.5 * 3600, avgHeartRate: 68),
    .init(day: "Sun", sleepDuration: 4.25 * 3600, avgHeartRate: 69),
]

struct SleepChart: View {
    @State private var sleepData = mockSleepStats
    var body: some View {
        Chart {
            ForEach(sleepData) { data in
                BarMark(
                    x: .value("WeekDay", data.day),
                    yStart: .value("SleepDurationStart", 0),
                    yEnd: .value("SleepDuration", data.sleepDuration / 3600 / 9),
                    width: .fixed(24)
                )
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 4,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 4
                    )
                )
                .foregroundStyle(by: .value("Value", "SleepDuration"))
            }
            
            ForEach(sleepData) { data in
                LineMark(
                    x: .value("WeekDay", data.day),
                    y: .value("HeartRate", Double(data.avgHeartRate) / 120.0),
                )
                .lineStyle(StrokeStyle(lineWidth: 2))
                .symbol {
                    ZStack {
                        Circle()
                            .fill(.white)
                            .frame(width: 6, height: 6)
                        Circle()
                            .stroke(Color(hexString: "#303030")!, lineWidth: 2)
                            .frame(width: 8, height: 8)
                    }
                }
                .foregroundStyle(by: .value("Value", "HeartRate"))
            }
        }
        .chartForegroundStyleScale([
            "SleepDuration": Color(hexString: "#9E6CEC")!,
            "HeartRate": Color(hexString: "#303030")!
        ])
        
        .chartYAxis {
            let defaultStride = Array(stride(from: 0, through: 1, by: 1.0 / 3))
            let heartRateStride = Array(stride(from: 40, through: 100, by: 20))
            let sleepDurationStride = Array(stride(from: 0, through: 9, by: 3))
            AxisMarks(position: .trailing, values: defaultStride) { value in
                AxisGridLine(
                    stroke: value.index == 0
                        ? StrokeStyle(lineWidth: 1)
                        : StrokeStyle(
                            lineWidth: 1,
                            dash: [value.index == 0 ? 0 : 2]
                        )
                )
                .foregroundStyle(
                    value.index == 0
                        ? Color(hexString: "#ACAFB6")!
                        : Color(hexString: "#D8DBDD")!
                )
                AxisValueLabel("\(heartRateStride[value.index])")
            }
            
            AxisMarks(position: .leading, values: defaultStride) { value in
                AxisValueLabel(value.index == 0 ? "0" : "\(sleepDurationStride[value.index])h", centered: false)
            }
        }
        .chartXAxis {
            AxisMarks {
                AxisTick(
                    centered: true,
                    length: 4,
                    stroke: StrokeStyle(lineWidth: 1)
                )
                AxisValueLabel()
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .padding()
    }
}

#Preview {
    SleepChart()
}
