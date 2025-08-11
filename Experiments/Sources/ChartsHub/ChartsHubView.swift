import SwiftUI

public struct ChartsHubView: View {
    public init() {}

    public var body: some View {
        Form {
            Section {
                HeartBeat()
            } header: {
                Text("Heart Beat")
                    .font(.title)
                    .foregroundStyle(Color.accentColor.gradient)
                    .bold()
            }

            Section {
                OneDimentionBar()
            } header: {
                Text("One Dimention Bar")
                    .font(.title)
                    .foregroundStyle(Color.accentColor.gradient)
                    .bold()
            }

            Section {
                FormChartView()
            } header: {
                Text("Form Chart")
                    .font(.title)
                    .foregroundStyle(Color.accentColor.gradient)
                    .bold()
            }

            Section {
                RecoveryStateCharts()
            } header: {
                Text("Gradient Chart")
                    .font(.title)
                    .foregroundStyle(Color.accentColor.gradient)
                    .bold()
            }

            Section {
                SleepChart()
            } header: {
                Text("Multiple Y Axis Chart")
                    .font(.title)
                    .foregroundStyle(Color.accentColor.gradient)
                    .bold()
            }
        }

        .navigationTitle("Charts")
    }
}
