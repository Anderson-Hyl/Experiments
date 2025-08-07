import Foundation
import Charts
import SwiftUI

struct OneDimentionBar: View {
    @State private var data = DataUsageData.example
    @State private var showLegend = true
    
    private var totalSize: Double {
        data.map(\.size).reduce(0, +)
    }
    var body: some View {
        VStack {
            HStack {
                Text("iPhone")
                Spacer()
                Text("\(totalSize, specifier: "%.1f") GB of 128 GB Used" )
                    .foregroundStyle(.secondary)
            }
            chart
            
            Toggle("Show Legend", isOn: $showLegend)
        }
        .padding()
    }
    
    private var chart: some View {
        Chart(data, id: \.category) { element in
            Plot {
                BarMark(x: .value("Data Size", element.size))
                    .foregroundStyle(by: .value("Data Category", element.category))
            }
        }
        .chartPlotStyle { plotArea in
            plotArea
                .background(
                    Color(.systemFill)
                )
                .cornerRadius(8)
        }
        .chartXAxis(.hidden)
        .chartXScale(domain: 0...128)
        .chartYScale(range: .plotDimension(endPadding: -8))
        .chartLegend(showLegend ? .visible : .hidden)
        .chartLegend(position: .bottom, spacing: 8)
        .frame(height: 50)
    }
}

#Preview {
    OneDimentionBar()
}
