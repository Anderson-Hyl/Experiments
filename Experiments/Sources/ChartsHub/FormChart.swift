import Charts
import SwiftUI

struct FormChartView: View {
    struct DataPoint: Identifiable {
        let id = UUID()
        let date: Date
        let value: Double
    }

    let values: [DataPoint] = (0..<30).map {
            DataPoint(
                date: Calendar.current.date(byAdding: .day, value: $0, to: .now)!,
                value: Double.random(in: -30...30)
            )
        }

    var body: some View {
        let startDate = values.first!.date
                let endDate = values.last!.date
        let customTicks: [Double] = [30, 15, 0, -10, -30, -35]
        Chart {
            // 填充区域
            
            ForEach(values) { point in
                RectangleMark(
                    xStart: .value("Start", startDate),
                    xEnd: .value("End", endDate),
                    yStart: .value("Y Start", -20),
                    yEnd: .value("Y End", -10)
                )
                .foregroundStyle(.pink.opacity(0.01))
                LineMark(
                            x: .value("Date", point.date),
                            y: .value("Value", point.value)
                        )
                .foregroundStyle(.primary)
                .interpolationMethod(.monotone)
            }
        }
        .chartYAxis {
            AxisMarks(position: .trailing, values: customTicks) {
                AxisGridLine()
                AxisTick()
                AxisValueLabel()
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 7)) { date in
                AxisValueLabel(format: .dateTime.month().day())
            }
        }
        .frame(height: 180)
        .padding()
    }
}

#Preview {
    FormChartView()
}
