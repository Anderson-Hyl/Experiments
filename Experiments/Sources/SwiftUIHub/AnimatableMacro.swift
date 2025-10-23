import SwiftUI

struct IntegerView: View {
    var number: Int
    var body: some View {
        Text(number.formatted())
    }
}

struct AnimatableWithoutMacroView: View {
    @State private var number = 0
    var body: some View {
        IntegerView(number: number)
            .animation(.default.speed(0.5), value: number)
        Button("Animate") {
            withAnimation {
                number = 100
            }
        }
    }
}


@available(iOS 26.0, macOS 26.0, *)
@Animatable
struct FloatView: View {
    var number: Float
    var body: some View {
        Text(number.formatted(.number.precision(.fractionLength(0))))
    }
}

@available(iOS 26.0, macOS 26.0, *)
struct AnimatableWithMacroView: View {
    @State private var number: Float = 0
    var body: some View {
        VStack {
            FloatView(number: number)
                .animation(.default.speed(0.5), value: number)
            Button("Animate") {
                number = 100
            }
        }
    }
}

#Preview {
    VStack {
        AnimatableWithoutMacroView()
        if #available(iOS 26.0, macOS 26.0, *) {
            AnimatableWithMacroView()
        } else {
            // Fallback on earlier versions
        }
    }
}

