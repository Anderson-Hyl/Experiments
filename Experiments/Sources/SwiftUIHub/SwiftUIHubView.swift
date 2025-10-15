import SwiftUI

public struct SwiftUIHubView: View {
    public init() {}
    public var body: some View {
        Form {
            Section {
                if #available(iOS 26.0, *) {
                    AnimatableWithMacroView()
                }
            } header: {
                Text("AnimatableMacro")
            }
        }
    }
}
