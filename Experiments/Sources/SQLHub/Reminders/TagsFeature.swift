import ComposableArchitecture
import SwiftUI
import SharingGRDB

@Reducer
public struct TagsReducer {
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        @FetchAll(Tag.all) var tags
        @Shared var selectedTags: [Tag]
        public init(selectedTags: Shared<[Tag]>) {
            self._selectedTags = selectedTags
        }
    }
    
    @CasePathable
    public enum Action: ViewAction {
        case view(View)
        
        public enum View {
            case onTask
            case removeSelectedTag(Tag.ID)
            case selectTag(Tag.ID)
            case onTappedDoneButton
        }
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(.removeSelectedTag(tagID)):
                state.$selectedTags.withLock {
                    $0.removeAll { $0.id == tagID }
                }
                return .none
            case let .view(.selectTag(tagID)):
                let tag = state.tags.first(where: { $0.id == tagID })
                guard let tag else {
                    return .none
                }
                state.$selectedTags.withLock {
                    $0.append(tag)
                }
                return .none
            case .view(.onTappedDoneButton):
                return .run { _ in
                    @Dependency(\.dismiss) var dismiss
                    await dismiss()
                }
            case .view:
                return .none
            }
        }
    }
}

@ViewAction(for: TagsReducer.self)
public struct TagsView: View {
    public let store: StoreOf<TagsReducer>
    public init(store: StoreOf<TagsReducer>) {
        self.store = store
    }
    public var body: some View {
        Form {
            Section {
                let selectedTagIDs = Set(store.selectedTags.map(\.id))
                ForEach(store.tags) { tag in
                    let isTagSelected = selectedTagIDs.contains(tag.id)
                    Button {
                        if isTagSelected {
                            send(.removeSelectedTag(tag.id))
                        } else {
                            send(.selectTag(tag.id))
                        }
                    } label: {
                        HStack {
                            if isTagSelected {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.accentColor.gradient)
                            }
                            Text(tag.title)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Done") {
                    send(.onTappedDoneButton)
                }
            }
        }
        .navigationTitle("Tags")
        .task {
            await send(.onTask).finish()
        }
    }
}
