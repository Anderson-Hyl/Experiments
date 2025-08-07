import SwiftUI
import Utils

struct SuuntoContainerBox<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    var body: some View {
        GroupBox {
            content
        }
        .groupBoxStyle(TransparentBorderedGroupBoxStyle())
    }
}

struct SleepContainerBox: View {
    var body: some View {
        SuuntoContainerBox {
            VStack(spacing: 18) {
                HStack(spacing: 16) {
                    Image(systemName: "moon.stars.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color(hexString: "#9E6CEC")!)
                    Text("Sleep")
                        .font(.system(size: 16, weight: .bold))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .resizable()
                        .scaledToFit()
                        .imageScale(.small)
                        .frame(width: 16, height: 16)
                }
                .foregroundStyle(.primary)
                
                ProportionalHStackLayout {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("05:45 h")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.primary)
                        Text("Last night")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }
                    .widthProportion(1)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("07:38 h")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.primary)
                        Text("7-d avg.")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }
                    .widthProportion(1)
                }
            }
        }
        .padding()
    }
}

struct SuuntoCoachCard: View {
    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "arrowshape.right.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                    Text("Keeping fit")
                        .font(.title3)
                        .bold()
                }
                .foregroundStyle(.pink.opacity(0.6))

                Text(
                    "Good job! You’re slowly improving your fitness. If you want to improve and be on productive training phase, try increasing the volume or intensity of your training."
                )
                .multilineTextAlignment(.leading)

            }
        }
        .groupBoxStyle(TransparentBorderedGroupBoxStyle())
        .padding()
    }
}

struct TransparentBorderedGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            configuration.label
                .font(.headline)
                .foregroundColor(.primary)

            configuration.content
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    Color(hexString: "#E9ECEE")!,
                    lineWidth: 1
                )  // 边框
        )
    }
}

#Preview {
    SleepContainerBox()
}
