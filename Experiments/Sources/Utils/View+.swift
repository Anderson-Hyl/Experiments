import SwiftUI

public struct FlippedUpsideDown: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .rotationEffect(.radians(.pi))
            .scaleEffect(x: -1, y: 1, anchor: .center)
    }
}

extension View {
    public func flippedUpsideDown() -> some View {
        modifier(FlippedUpsideDown())
    }
}
