import SwiftUI

struct PageControlSegmentView: View {
    enum SegmentState: Equatable {
        case inactive, active(progress: Double)
        
        var progress: Double {
            switch self {
            case .inactive: 0
            case .active(let progress): progress
            }
        }
        var isActive: Bool {
            guard case .active = self else {
                return true
            }
            return false
        }
    }
    var state: SegmentState
    private var segmentWidth: CGFloat {
        switch state {
        case .inactive: 6
        case .active: 15
        }
    }
    private var segmentProgressWidth: CGFloat {
        switch state {
        case .inactive: 0
        case .active(let progress): segmentWidth * progress
        }
    }
    private let minWidth: CGFloat = 6
    private let maxWidth: CGFloat = 15
    private let height: CGFloat = 6
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.secondary)
                .frame(width: segmentWidth, height: height)
                .animation(.none, value: state.progress)
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.primary)
                .frame(width: segmentProgressWidth, height: height)
        }
        .animation(!state.isActive ? .snappy(duration: 2) : .none, value: state.progress)
    }
}

struct PageIndicatorView: View {
    var pageCount: Int
    @Binding var currentIndex: Int
    @Binding var isAutoPlaying: Bool
    var perPageDuration: Double = 2
    var spacing: CGFloat = 6
    @State private var progress: Double = 0
    @State private var autoPlayTask: Task<Void, Error>? = nil
    var body: some View {
        HStack {
            ForEach(0..<pageCount, id: \.self) { index in
                let state: PageControlSegmentView.SegmentState = {
                    if index == currentIndex { return PageControlSegmentView.SegmentState.active(progress: progress) }
                    return .inactive
                }()
                PageControlSegmentView(state: state)
            }
        }
        .task {
            startAutoPlay()
        }
        .onDisappear {
            stopAutoPlay()
        }
        .onChange(of: currentIndex) {
            if isAutoPlaying {
                restartAutoPlay()
            }
        }
        .onChange(of: isAutoPlaying) {
            if isAutoPlaying {
                startAutoPlay()
            } else {
                stopAutoPlay()
            }
        }
    }
    
    private func restartAutoPlay() {
        stopAutoPlay()
        startAutoPlay()
    }
    
    private func stopAutoPlay() {
        autoPlayTask?.cancel() // 关键：取消任务
        autoPlayTask = nil
        isAutoPlaying = false
    }
    
    private func startAutoPlay() {
        guard autoPlayTask == nil else {
            return
        }
        isAutoPlaying = true
        autoPlayTask = Task {
            var currentPageIndex = currentIndex
            while !Task.isCancelled {
                currentPageIndex = (currentPageIndex % pageCount)
                currentIndex = currentPageIndex
                progress = 0
                
                let totalDuration = perPageDuration
                await MainActor.run {
                    withAnimation(.linear(duration: totalDuration)) {
                        progress = 1
                    }
                }
                do {
                    try await Task.sleep(for: .seconds(totalDuration))
                } catch is CancellationError {
                    return
                } catch {
                    break
                }
                currentPageIndex += 1
            }
        }
    }
}

#Preview {
    @Previewable @State var currentIndex = 0
    @Previewable @State var isPlaying = false
    VStack {
        PageIndicatorView(pageCount: 6, currentIndex: $currentIndex, isAutoPlaying: $isPlaying)
        Button("Next Step") {
            isPlaying.toggle()
        }
        .buttonStyle(.bordered)
    }
}
