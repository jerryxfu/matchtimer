import SwiftUI

struct LiveStatusBadge: View {
    let text: String
    let color: Color
    let icon: String?
    let isLive: Bool

    @State private var blinkOn = true

    init(text: String, color: Color, icon: String? = nil, isLive: Bool) {
        self.text = text
        self.color = color
        self.icon = icon
        self.isLive = isLive
    }

    var body: some View {
        HStack(spacing: 5) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 10))
            }

            Text(text)
                .font(.system(size: 11, weight: .medium))

            if isLive {
                Circle()
                    .fill(color)
                    .frame(width: 6, height: 6)
                    .opacity(blinkOn ? 1.0 : 0.25)
                    .onAppear {
                        withAnimation(
                            .easeInOut(duration: 0.8).repeatForever(
                                autoreverses: true
                            )
                        ) {
                            blinkOn = false
                        }
                    }
            }
        }
        .foregroundStyle(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}
