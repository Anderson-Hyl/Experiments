import SwiftUI

struct TreeMapRect: Identifiable {
    let id = UUID()
    var x: Double
    var y: Double
    var width: Double
    var height: Double
    var value: Double
}

struct SwiftTreeMap {
    enum FrameAlignment { case highPrecision, retinaSubPixel, integral }

    var values: [Double]
    var alignment: FrameAlignment = .retinaSubPixel

    var normalizedWeights: [Double] {
        let total = values.reduce(0, +)
        return values.map { $0 / total }
    }

    func computeRects(in frame: CGRect) -> [TreeMapRect] {
        let base = Rect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height)
        let rawRects = tessellate(weights: normalizedWeights, inRect: base)
        return zip(rawRects, values).map {
            TreeMapRect(
                x: $0.x,
                y: $0.y,
                width: $0.width,
                height: $0.height,
                value: $1
            )
        }
    }

    // MARK: - Internal types

    struct Rect {
        var x, y, width, height: Double
        mutating func align(using a: FrameAlignment) {
            guard a != .highPrecision else { return }
            let maxX = x + width, maxY = y + height
            x = align(x, a); y = align(y, a)
            width = align(maxX, a) - x; height = align(maxY, a) - y
        }
        private func align(_ p: Double, _ a: FrameAlignment) -> Double {
            let (i, f) = modf(p)
            let s = a == .retinaSubPixel
            if s && f < 0.25 { return i }
            else if f < 0.5 { return i + 0.5 }
            else if s && f < 0.75 { return i + 0.5 }
            else { return i + 1 }
        }
    }

    enum Axis { case horizontal, vertical }

    func tessellate(weights: [Double], inRect rect: Rect) -> [Rect] {
        var areas = weights.map { $0 * rect.width * rect.height }
        var result: [Rect] = [], canvas = rect
        while !areas.isEmpty {
            var remaining = canvas
            let group = tessellateRow(areas: areas, inRect: canvas, remaining: &remaining)
            result += group; canvas = remaining; areas.removeFirst(group.count)
        }
        return result
    }

    func tessellateRow(areas: [Double], inRect rect: Rect, remaining: inout Rect) -> [Rect] {
        let dir: Axis = rect.width >= rect.height ? .horizontal : .vertical
        let length = dir == .horizontal ? rect.height : rect.width

        var aspect = Double.greatestFiniteMagnitude
        var accepted: [Double] = [], accWeight: Double = 0

        for area in areas {
            let newAspect = worstAspectRatio(for: accepted, sum: accWeight, proposed: area, length: length, limit: aspect)
            if newAspect > aspect { break }
            accepted.append(area); accWeight += area; aspect = newAspect
        }

        let w = accWeight / length
        var offset = dir == .horizontal ? rect.y : rect.x
        let result = accepted.map { a in
            let h = a / w, o = offset; offset += h
            var r = dir == .horizontal
                ? Rect(x: rect.x, y: o, width: w, height: h)
                : Rect(x: o, y: rect.y, width: h, height: w)
            r.align(using: alignment); return r
        }

        switch dir {
        case .horizontal:
            remaining = Rect(x: rect.x + w, y: rect.y, width: rect.width - w, height: rect.height)
        case .vertical:
            remaining = Rect(x: rect.x, y: rect.y + w, width: rect.width, height: rect.height - w)
        }
        return result
    }

    func worstAspectRatio(for ws: [Double], sum: Double, proposed: Double, length: Double, limit: Double) -> Double {
        let total = sum + proposed, width = total / length
        var worst = aspect(width, proposed / width)
        for w in ws {
            worst = max(worst, aspect(width, w / width))
            if worst > limit { break }
        }
        return worst
    }

    func aspect(_ a: Double, _ b: Double) -> Double { max(a / b, b / a) }
}


struct TreemapView: View {
    let values: [Double]
    var body: some View {
        GeometryReader { geo in
            let treemap = SwiftTreeMap(values: values)
            let rects = treemap.computeRects(in: geo.frame(in: .local))

            ZStack {
                ForEach(rects) { rect in
                    Button {
                        
                    } label: {
                        Rectangle()
                            .fill(Color.black.gradient)
                            .frame(width: rect.width - 1, height: rect.height - 1)
                            .position(x: rect.x + rect.width/2, y: rect.y + rect.height/2)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#Preview {
    TreemapView(values: (1...20).map { _ in Double.random(in: 0.2...1.0) })
}


