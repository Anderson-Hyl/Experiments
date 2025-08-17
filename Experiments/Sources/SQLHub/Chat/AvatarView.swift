import SwiftUI
import Kingfisher

public enum AvatarSize {
	case small, medium, large
	
	var size: CGFloat {
		switch self {
		case .small: 24
		case .medium: 36
		case .large: 48
		}
	}
}

public struct SpaceAvatarView: View {
	public let avatarSize: AvatarSize
	public let space: Space
	public let user: User
	public init(avatarSize: AvatarSize, space: Space, user: User) {
		self.avatarSize = avatarSize
		self.space = space
		self.user = user
	}
	
	public var body: some View {
		AvatarView(
			avatarSize: avatarSize,
			user: user
		) {
			let image = switch space.kind {
			case .direct: Image(systemName: "person.circle.fill")
			case .group: Image(systemName: "person.2.circle.fill")
			case .system: Image(systemName: "paperplane.circle.fill")
			}
			return image
				.resizable()
				.frame(width: avatarSize.size, height: avatarSize.size)
				.foregroundStyle(Color.accentColor.gradient)
				.font(.title)
		}
	}
}

public struct AvatarView<Placeholder: View>: View {
	public let avatarSize: AvatarSize
	public let user: User
	public var placeholder: Placeholder
	public init(
		avatarSize: AvatarSize,
		user: User,
		@ViewBuilder placeholder: () -> Placeholder
	) {
		self.avatarSize = avatarSize
		self.user = user
		self.placeholder = placeholder()
	}
	
	public var body: some View {
		KFImage.url(URL(string: user.avatarURL ?? ""))
			.placeholder {
				placeholder
			}
			.setProcessor(avatarProcessor)
			.loadDiskFileSynchronously()
			.cacheOriginalImage()
			.fade(duration: 0.25)
	}
	
	private var avatarProcessor: some ImageProcessor {
		RoundCornerImageProcessor(
			cornerRadius: avatarSize.size / 2,
			targetSize: CGSize(width: avatarSize.size, height: avatarSize.size),
			roundingCorners: .all
		)
	}
}

