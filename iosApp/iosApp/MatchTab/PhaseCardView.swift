import ComposeApp
import SwiftUI

struct PhaseCardView: View {
    let phase: MatchPhase
    let isActive: Bool
    let isPast: Bool
    let phaseSecondsRemaining: Int32
    var activeNamespace: Namespace.ID

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(isPast || isActive ? phaseColor : Color(.systemGray4))
                .frame(
                    width: TimelineLayout.dotSize,
                    height: TimelineLayout.dotSize
                )
                .padding(.top, TimelineLayout.dotTopPadding)
                .animation(.easeInOut(duration: 0.3), value: isActive)
                .frame(width: TimelineLayout.dotColumnWidth)
                .zIndex(1)

            cardContent

            durationLabel
        }
    }

    private var cardContent: some View {
        ZStack {
            if isActive {
                RoundedRectangle(cornerRadius: 12)
                    .fill(phaseColor.opacity(0.08))
                    .matchedGeometryEffect(
                        id: "activeBackground",
                        in: activeNamespace
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(phaseColor, lineWidth: 1.5)
                            .matchedGeometryEffect(
                                id: "activeBorder",
                                in: activeNamespace
                            )
                    )
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray5), lineWidth: 0.5)
                    )
            }

            VStack(alignment: .leading, spacing: 4) {
                if !title.isEmpty {
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(isActive ? phaseColor : Color.primary)
                        .animation(.easeInOut(duration: 0.3), value: isActive)
                }

                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.secondary)
                }

                if isActive && phaseSecondsRemaining > 0 {
                    Text("\(phaseSecondsRemaining)s left")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(phaseColor)
                        .contentTransition(.numericText(countsDown: true))
                }

                if let shift = phase as? MatchPhase.AllianceShift {
                    HubBadgesView(activeAlliance: shift.activeAlliance)
                        .padding(.top, 2)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .opacity(isPast ? 0.4 : 1.0)
        .animation(.spring(duration: 0.4), value: isActive)
    }

    private var durationLabel: some View {
        Text(duration)
            .font(.system(size: 12))
            .foregroundStyle(Color.secondary)
            .padding(.top, 14)
            .frame(width: 32)
    }

    var phaseColor: Color {
        switch phase {
        case is MatchPhase.Auto: return .green
        case is MatchPhase.AutoEndPause: return .green
        case is MatchPhase.Transition: return .green
        case is MatchPhase.AllianceShift: return .green
        case is MatchPhase.Endgame: return .orange
        default: return Color(.systemGray4)
        }
    }

    private var title: String {
        switch phase {
        case is MatchPhase.Auto: return "Autonomous"
        case is MatchPhase.Transition: return "Transition"
        case let s as MatchPhase.AllianceShift:
            return "Alliance shift \(s.number)"
        case is MatchPhase.Endgame: return "Endgame"
        case is MatchPhase.MatchEnded: return "Match over"
        default: return ""
        }
    }

    private var subtitle: String {
        switch phase {
        case is MatchPhase.Auto: return "Both hubs active"
        case is MatchPhase.AutoEndPause: return "Pause"
        case is MatchPhase.Transition: return "Both hubs active"
        case is MatchPhase.Endgame: return "Both hubs active"
        default: return ""
        }
    }

    private var duration: String {
        switch phase {
        case is MatchPhase.Auto: return "20s"
        case is MatchPhase.AutoEndPause: return "3s"
        case is MatchPhase.Transition: return "10s"
        case is MatchPhase.AllianceShift: return "25s"
        case is MatchPhase.Endgame: return "30s"
        default: return "—"
        }
    }
}

struct HubBadgesView: View {
    let activeAlliance: Alliance?

    var body: some View {
        HStack(spacing: 6) {
            badge(alliance: .red)
            badge(alliance: .blue)
        }
    }

    private func badge(alliance: Alliance) -> some View {
        let isActive = activeAlliance == alliance
        let color: Color = alliance == .red ? .red : .blue

        return Text(alliance == .red ? "Red" : "Blue")
            .font(.system(size: 11, weight: .medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(isActive ? color.opacity(0.12) : Color(.systemGray6))
            .foregroundStyle(isActive ? color : Color.secondary)
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}
