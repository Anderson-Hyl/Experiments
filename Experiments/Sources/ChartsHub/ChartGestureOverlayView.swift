//
//  ChartGestureOverlayView.swift
//  Experiment
//
//  Created by anderson on 2025/8/4.
//


import Charts
import Foundation
import SwiftUI
import UIKit

/// Overlay view for chart gestures. Use when GeometryProxy is not already present.
@MainActor
struct ChartGestureOverlayView<X, Y>: View where X: Plottable, Y: Plottable {
    let chartProxy: ChartProxy
    let onGesture: (_ x: X, _ y: Y) -> Void
    let onEnd: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ChartGestureOverlayContentView(
                chartProxy: chartProxy,
                geometry: geometry,
                onGesture: onGesture,
                onEnd: onEnd
            )
        }
    }
}

/// Internal gesture handler. Use when GeometryProxy is already available.
struct ChartGestureOverlayContentView<X, Y>: View where X: Plottable, Y: Plottable {
    let chartProxy: ChartProxy
    let geometry: GeometryProxy
    let onGesture: (_ x: X, _ y: Y) -> Void
    let onEnd: () -> Void
    
    var body: some View {
        Rectangle()
            .fill(.clear)
            .contentShape(Rectangle())
            .gesture(
                LongPressGesture(minimumDuration: 0.1)
                    .sequenced(before: DragGesture(minimumDistance: 0))
                    .onChanged { value in
                        guard case .second(true, let drag?) = value else { return }
                        
                        let origin = geometry[chartProxy.plotAreaFrame].origin
                        let location = CGPoint(
                            x: drag.location.x - origin.x,
                            y: drag.location.y - origin.y
                        )
                        
                        if let (x, y) = chartProxy.value(at: location, as: (X, Y).self) {
                            onGesture(x, y)
                        }
                    }
                    .onEnded { _ in onEnd() }
            )
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                onEnd()
            }
            .onDisappear {
                onEnd()
            }
    }
}

struct ChartGestureOverlayUIView<X, Y>: View where X: Plottable, Y: Plottable {
    let chartProxy: ChartProxy
    let onGesture: (_ x: X, _ y: Y) -> Void
    let onEnd: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ChartGestureOverlayContentUIView(
                chartProxy: chartProxy,
                geometry: geometry,
                onGesture: onGesture,
                onEnd: onEnd
            )
        }
    }
}

@MainActor
struct ChartGestureOverlayContentUIView<X, Y>: UIViewRepresentable where X: Plottable, Y: Plottable {
    let chartProxy: ChartProxy
    let geometry: GeometryProxy
    let onGesture: (_ x: X, _ y: Y) -> Void
    let onEnd: () -> Void
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        
        let longPressGesture = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.1
        view.addGestureRecognizer(longPressGesture)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.chartProxy = chartProxy
        context.coordinator.geometry = geometry
        context.coordinator.onGesture = onGesture
        context.coordinator.onEnd = onEnd
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject {
        var chartProxy: ChartProxy?
        var geometry: GeometryProxy?
        var onGesture: ((_ x: X, _ y: Y) -> Void)?
        var onEnd: (() -> Void)?
        private var isLongPressing = false
        
        @MainActor @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
            guard let chartProxy = chartProxy,
                let geometry = geometry,
                let onGesture = onGesture,
                let onEnd = onEnd else { return }
            
            switch gesture.state {
            case .began:
                isLongPressing = true
            case .changed:
                if isLongPressing {
                    let location = gesture.location(in: gesture.view)
                    let origin = geometry[chartProxy.plotAreaFrame].origin
                    let chartLocation = CGPoint(
                        x: location.x - origin.x,
                        y: location.y - origin.y
                    )
                    
                    if let (x, y) = chartProxy.value(at: chartLocation, as: (X, Y).self) {
                        onGesture(x, y)
                    }
                }
            case .ended, .cancelled:
                isLongPressing = false
                onEnd()
            default:
                break
            }
        }
    }
}
