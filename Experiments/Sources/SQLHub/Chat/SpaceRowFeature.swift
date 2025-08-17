import ComposableArchitecture
import Kingfisher
import SharingGRDB
import SwiftUI

@Reducer
public struct SpaceRowReducer {
	public init() {}
    
	@ObservableState
	public struct State: Equatable, Identifiable {
		public var id: UUID {
			space.id
		}

		var space: Space
		@Fetch
		var spaceRowValue: SpaceRowRequest.Value
		public init(space: Space) {
			self.space = space
			self._spaceRowValue = Fetch(
				wrappedValue: .placeholder,
				SpaceRowRequest(spaceID: space.id, authUserID: UUID(0))
			)
		}
			
		struct SpaceRowRequest: FetchKeyRequest, Equatable {
			let spaceID: Space.ID
			let authUserID: User.ID
			struct Value: Equatable, Sendable, Identifiable {
				var user: User
				var lastMessage: Message?
				var id: User.ID { user.id }
				
				static let placeholder = Value(user: .placeholder)
			}

			func fetch(_ db: Database) throws -> Value {
				try Value(
					user: SpaceParticipant
						.where { $0.spaceID.eq(spaceID) && $0.userID.neq(authUserID) }
						.join(User.all) { $0.userID.eq($1.id) }
						.limit(1)
						.select { $1 }
						.fetchOne(db)!
					,
					lastMessage: Message
						.where { $0.spaceID.eq(spaceID) }
						.order { $0.createdAt.desc() }
						.limit(1)
						.fetchOne(db)
				)
			}
		}
	}
    
	public enum Action: ViewAction {
		case view(View)
        
		public enum View {
			case onTask
		}
	}
    
	public var body: some ReducerOf<Self> {
		Reduce { _, action in
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
			VStack(alignment: .leading, spacing: 4) {
				Text(store.spaceRowValue.user.displayName)
					.font(.headline)
					.fontWeight(.semibold)
				Text(store.spaceRowValue.lastMessage?.text ?? "")
					.lineLimit(1)
					.font(.subheadline)
					.foregroundStyle(Color.secondary.gradient)
			}
			Spacer()
		}
		.contentShape(.rect)
	}
	
	private var avatarProcessor: some ImageProcessor {
		RoundCornerImageProcessor(
			cornerRadius: 24,
			targetSize: CGSize(width: 48, height: 48),
			roundingCorners: .all
		)
	}
	
	private var avatarView: some View {
		KFImage.url(URL(string: store.spaceRowValue.user.avatarURL ?? ""))
			.placeholder {
				avatarPlaceholderView
			}
			.setProcessor(avatarProcessor)
			.loadDiskFileSynchronously()
			.cacheOriginalImage()
			.fade(duration: 0.25)
	}
	
	private var avatarPlaceholderView: some View {
		let image = switch store.space.kind {
		case .direct: Image(systemName: "person.circle.fill")
		case .group: Image(systemName: "person.2.circle.fill")
		case .system: Image(systemName: "paperplane.circle.fill")
		}
		return image
			.resizable()
			.frame(width: 48, height: 48)
			.foregroundStyle(Color.accentColor.gradient)
			.font(.title)
	}
}
