import Charts
import Foundation
import SwiftUI

struct HeartBeat: View {
    @State private var data = HealthData.ecgSample
    @State private var lineWidth = 2.0
    @State private var interpolationMethod: InterpolationMethod = .cardinal
    @State private var chartColor: Color = .pink
    @State private var showGrid = true

    @State private var minValueScale: CGFloat = 1.0
    @State private var maxValueScale: CGFloat = 1.0
    @State private var tapLocation: CGPoint? = nil
    var body: some View {
        chartAndLabels
    }

    private var chartAndLabels: some View {
        VStack(alignment: .leading) {
            Text("Sinus Rhythm")
                .font(.system(.title2, design: .rounded))
                .bold()
            Group {
                Text(Date(), style: .date) + Text(" at ")
                    + Text(Date(), style: .time)
            }
            .foregroundStyle(.secondary)
            Group {
                if showGrid {
                    chartWithGrid
                } else {
                    plainChart
                }
            }
            .padding()

            Toggle("Show Grid", isOn: $showGrid)
        }
        .padding()
        .frame(height: 300)
    }

    private var chartWithGrid: some View {
        chart
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 12)) { value in
                    if let doubleValue = value.as(Double.self),
                        let intValue = value.as(Int.self)
                    {
                        if doubleValue - Double(intValue) == 0 {
                            AxisTick(stroke: StrokeStyle(lineWidth: 1))
                                .foregroundStyle(.gray)
                            AxisValueLabel {
                                Text("\(intValue) s")
                            }
                            AxisGridLine(stroke: .init(lineWidth: 1))
                                .foregroundStyle(.gray)
                        } else {
                            AxisGridLine(stroke: .init(lineWidth: 1))
                                .foregroundStyle(.gray.opacity(0.25))
                        }
                    }
                }
            }
            .chartYScale(domain: -400...800)
            .chartYAxis {
                AxisMarks(values: .automatic(desiredCount: 14)) { value in
                    AxisGridLine(stroke: .init(lineWidth: 1))
                        .foregroundStyle(.gray.opacity(0.25))
                    if value.index % 5 == 0 {
                        AxisValueLabel {
                            Text("\(value.index)")
                        }
                    }
                }
            }
            .chartPlotStyle {
                $0.border(Color.gray)
            }
    }

    private var plainChart: some View {
        chart
            .chartYAxis(.hidden)
            .chartXAxis(.hidden)
    }

    private var minIndex: Int? {
        data.firstIndex(of: data.min() ?? 0)
    }

    private var maxIndex: Int? {
        data.firstIndex(of: data.max() ?? 0)
    }

    private var chart: some View {
        Chart {
            ForEach(Array(data.enumerated()), id: \.element) {
                index,
                value in
                LineMark(
                    x: .value("Seconds", Double(index) / 400.0),
                    y: .value("Unit", value)
                )
                .interpolationMethod(.monotone)
                .foregroundStyle(.red)
                .lineStyle(StrokeStyle(lineWidth: 2))
                .symbol(
                    Circle().strokeBorder(
                        lineWidth: index == data.firstIndex(of: data.max() ?? 0)
                            || index == data.firstIndex(of: data.min() ?? 0)
                            ? 2 : 0
                    )
                )
                .symbolSize(
                    index == data.firstIndex(of: data.max() ?? 0)
                        || index == data.firstIndex(of: data.min() ?? 0)
                        ? 36 : 0
                )

                if index == maxIndex {
                    PointMark(
                        x: .value("Seconds", Double(index) / 400.0),
                        y: .value("Unit", value)
                    )
                    .foregroundStyle(.clear)
                    .annotation(position: .top, spacing: 0) {
                        Text("Max. \(Int(value))")
                            .font(.system(size: 6))
                            .foregroundStyle(.red)
                            .bold()
                            .scaleEffect(maxValueScale)
                    }
                }

                if index == minIndex {
                    PointMark(
                        x: .value("Seconds", Double(index) / 400.0),
                        y: .value("Unit", value)
                    )
                    .foregroundStyle(.clear)
                    .annotation(position: .bottom, spacing: 0) {
                        Text("Min. \(Int(value))")
                            .font(.system(size: 6))
                            .foregroundStyle(.red)
                            .bold()
                            .scaleEffect(minValueScale)
                    }
                }
            }
        }
        .chartOverlay { proxy in
            GeometryReader { geometry in
                Rectangle()
                    .fill(.clear)
                    .contentShape(.rect)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onEnded { value in
                                let location = value.location

                                // 将点击位置映射为 Chart 的 x 值
                                if let tappedX: Double = proxy.value(atX: location.x) {
                                    checkIfTappedMinMaxPoint(tappedX: tappedX)
                                }
                            }
                    )
            }
        }
    }
    
    func checkIfTappedMinMaxPoint(tappedX: Double) {
        let minX = Double(minIndex ?? 0) / 400.0
        let maxX = Double(maxIndex ?? 0) / 400.0
        let threshold = 0.1 // 容许点击误差

        if abs(tappedX - minX) < threshold {
            triggerMinPointAnimation()
        } else if abs(tappedX - maxX) < threshold {
            triggerMaxPointAnimation()
        }
    }
    
    func triggerMinPointAnimation() {
        withAnimation(.smooth) {
            minValueScale = 2.0
        }
    }
    
    func triggerMaxPointAnimation() {
        withAnimation(.smooth) {
            maxValueScale = 2.0
        }
    }
}

#Preview {
    HeartBeat()
}
