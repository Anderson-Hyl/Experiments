import SwiftUI

public struct SwiftUIHubView: View {
    public init() {}
    public var body: some View {
        Form {
            Section {
                if #available(iOS 26.0, *) {
                    NavigationLink {
                        AnimatableWithMacroView()
                    } label: {
                        Text("AnimatableMacro")
                    }
                }
                NavigationLink {
                    LandmarkTipsView()
                } label: {
                    Text("TipsKit")
                }

            }
        }
    }
}

#Preview {
    NavigationStack {
        SwiftUIHubView()
    }
}
