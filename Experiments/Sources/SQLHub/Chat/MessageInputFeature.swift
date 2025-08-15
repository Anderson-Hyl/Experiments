import Foundation
import SwiftUI
import ComposableArchitecture

@Reducer
public struct MessageInputReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		var message: String = ""
		public init() {}
	}
	public enum Action: BindableAction {
		case binding(BindingAction<State>)
		case updateMessageInput(String)
		case onTapSendButton
		case clearInputTextField
		case delegate(Delegate)
		
		public enum Delegate {
			case onTapSendButton(String)
		}
	}
	
	public var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce { state, action in
			switch action {
			case .binding:
				return .none
			case let .updateMessageInput(message):
				state.message = message
				return .none
			case .onTapSendButton:
				guard !state.message.isEmpty else {
					return .none
				}
				return .run { [message = state.message] send in
					await send(.delegate(.onTapSendButton(message)))
					await send(.clearInputTextField)
				}
			case .clearInputTextField:
				state.message = ""
				return .none
			case .delegate:
				return .none
			}
		}
	}
}

public struct MessageInputView: View {
	@Bindable public var store: StoreOf<MessageInputReducer>
	public init(store: StoreOf<MessageInputReducer>) {
		self.store = store
	}
	public var body: some View {
		HStack {
			Button {
				
			} label: {
				Image(systemName: "face.dashed")
					.resizable()
					.scaledToFit()
                    .foregroundStyle(Color.accentColor.gradient)
			}
            .buttonStyle(.plain)
			.frame(width: 24, height: 24)
            TextField(
                "Message...",
                text: $store.message.sending(\.updateMessageInput),
                axis: .vertical
            )
				.textFieldStyle(.plain)
                .font(.body)
				.fontWeight(.semibold)
                .tint(.accentColor)
			Group {
				if store.message.isEmpty {
					EmptyView()
				} else {
					Button {
						store.send(.onTapSendButton)
					} label: {
						Image(systemName: "paperplane.fill")
							.resizable()
							.scaledToFit()
							.rotationEffect(.degrees(45))
                            .foregroundStyle(Color.accentColor.gradient)
					}
					.scaleEffect()
					.frame(width: 24, height: 24)
				}
			}
            .foregroundStyle(.primary)
		}
		.padding(.horizontal, 16)
		.padding(.vertical, 16)
		.background(
            Color(.systemGray6)
		)
		.clipShape(.rect(cornerRadius: 28))
		.padding()
	}
}
