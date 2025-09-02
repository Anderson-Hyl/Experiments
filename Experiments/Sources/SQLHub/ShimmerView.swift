import Foundation
import SwiftUI

public struct ShimmerView: View {
    @State private var startPoint = UnitPoint(x: -1.8, y: -1.2)
    @State private var endPoint = UnitPoint(x: 0, y: -0.2)
    
    public init() {}
    
    public var body: some View {
        LinearGradient(
            colors: [
                Color.gray.opacity(0.25),
                Color.white.opacity(0.8),
                Color.gray.opacity(0.25),
            ],
            startPoint: startPoint,
            endPoint: endPoint
        )
        .redacted(reason: .placeholder)
        .onAppear {
            withAnimation(
                .easeInOut(duration: 1.5)
                .repeatForever(autoreverses: false)
            ) {
                startPoint = UnitPoint(x: 1, y: 1.2)
                endPoint = UnitPoint(x: 2.2, y: 2.4)
            }
        }
    }
}

#Preview {
    GroupBox {
        HStack {
            Image(systemName: "person.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 54, height: 54)
            VStack(alignment: .leading, spacing: 6) {
                Text("User Name")
                    .font(.headline)
                Text("message content")
                    .redacted(reason: .placeholder)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }
    .frame(maxWidth: .infinity)
    .padding()
}
