//
//  Triangle.swift
//  Experiment
//
//  Created by anderson on 2025/8/4.
//

import SwiftUI

public struct Triangle: View {
    let height: CGFloat
    public init(height: CGFloat) {
        self.height = height
    }
    private var width: CGFloat {
        height * 1.2
    }
    
    public var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: width, y: 0))
            path.addLine(to: CGPoint(x: width / 2.0, y: height))
            path.addLine(to: CGPoint(x: width / 2.0, y: height))
        }
        .frame(width: width, height: height)
    }
}
