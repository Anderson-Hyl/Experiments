import SwiftUI

private struct WidthProportionKey: LayoutValueKey {
    static let defaultValue: CGFloat = 1
}

public extension View {
    func widthProportion(_ value: CGFloat) -> some View {
        layoutValue(key: WidthProportionKey.self, value: value)
    }
}

public struct ProportionalHStackLayout: Layout {
    let spacing: CGFloat
    public init(spacing: CGFloat = 8) {
        self.spacing = spacing
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        // 以传入 proposal 的宽度为主
        let totalWidth = proposal.width ?? 0
        let totalHeight = subviews.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
        return CGSize(width: totalWidth, height: totalHeight)
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard !subviews.isEmpty else { return }

        let totalPropotion = subviews.map { $0[WidthProportionKey.self] }.reduce(0, +)
        let availableWidth = bounds.width - spacing * CGFloat(subviews.count - 1)

        var x = bounds.minX

        for (_, subview) in subviews.enumerated() {
            let proportion = subview[WidthProportionKey.self]
            let width = availableWidth * (proportion / totalPropotion)
            let height = subview.sizeThatFits(.unspecified).height

            subview.place(
                at: CGPoint(x: x, y: bounds.midY - height / 2),
                proposal: ProposedViewSize(width: width, height: bounds.height)
            )

            x += width + spacing
        }
    }
}
