import SwiftUI
import ComposableArchitecture
import SharingGRDB

@Reducer
public struct SpaceRowReducer {
    public init() {}
    
    @ObservableState
    public struct State: Equatable, Identifiable {
        public var id: UUID {
            space.id
        }
        var space: Space
        public init(space: Space) {
            self.space = space
        }
    }
    
    public enum Action: ViewAction {
        case view(View)
        
        public enum View {
            case onTask
        }
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(.onTask):
                return .none
            }
        }
    }
}

@ViewAction(for: SpaceRowReducer.self)
public struct SpaceRowView: View {
    @Bindable public var store: StoreOf<SpaceRowReducer>
    public init(store: StoreOf<SpaceRowReducer>) {
        self.store = store
    }
    
    public var body: some View {
        HStack {
            avatarView
                .resizable()
                .foregroundStyle(Color.accentColor.gradient)
                .font(.title)
                .frame(width: 56, height: 56)
            VStack(alignment: .leading, spacing: 4) {
                Text(store.space.title ?? "Space")
                    .font(.headline)
                    .fontWeight(.semibold)
                Text("Some message")
                    .font(.subheadline)
                    .foregroundStyle(Color.secondary.gradient)
            }
            Spacer()
        }
        .contentShape(.rect)
    }
    
    private var avatarView: Image {
        switch store.space.kind {
        case .direct: Image(systemName: "person.circle.fill")
        case .group: Image(systemName: "person.2.circle.fill")
        case .system: Image(systemName: "paperplane.circle.fill")
        }
    }
}
