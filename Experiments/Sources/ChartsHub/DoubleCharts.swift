import Charts
import SwiftUI

struct TrainingData: Identifiable {
    var id = UUID()
    var day: String
    var hours: Double
    var preHours: Double
    var category: Category  // 代表左右哪边的 Bar
}

enum Category: String, Plottable, CaseIterable {
    case actual = "Actual"
    case goal = "Goal"
}

let trainingData: [TrainingData] = [
    .init(day: "Mon", hours: 2, preHours: 0, category: .actual),
    .init(day: "Mon", hours: 0, preHours: 0.8, category: .goal),
    .init(day: "Tue", hours: 7.5, preHours: 0, category: .actual),
    .init(day: "Tue", hours: 0, preHours: 4, category: .goal),
    // ...以此类推
]

struct DoubleCharts: View {
    var body: some View {
        Chart(trainingData) { item in
            Plot {
                BarMark(
                    x: .value("Day", item.day),
                    y: .value("Hours", item.hours)
                )
                .position(by: .value("Type", "Actual"))
                .foregroundStyle(by: .value("Category", item.category))
                BarMark(
                    x: .value("Day", item.day),
                    y: .value("Hours", item.preHours)
                )
                .position(by: .value("Type", "Goal"))
                .foregroundStyle(by: .value("Category", item.category))
            }
        }
        .chartForegroundStyleScale([
            Category.actual: .mint,
            Category.goal: .gray,
        ])
        .chartYAxis {
            AxisMarks(position: .trailing) {
                AxisGridLine()
                //                AxisValueLabel(format: .number.precision(.fractionLength(0)))
            }
        }
    }
}

#Preview {
    DoubleCharts()
}
