import SwiftUI

#Preview {
    @Previewable @State var volume: CGFloat = 20
    VStack(spacing: 36) {
        Gauge(value: 20, in: 0...100) {
            
        } currentValueLabel: {
            Text("\(Int(20))°C")
        }
        .tint(.orange)
        
        ProgressView(value: 0.2, total: 1.0)
            .tint(.green)
        
        Slider(value: $volume, in: 0...100) {
            Text("Volume")
        }
        .tint(.blue)
    }
    .padding()
}
