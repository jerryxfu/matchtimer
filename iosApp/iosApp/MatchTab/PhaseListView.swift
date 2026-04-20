import ComposeApp
import SwiftUI

enum TimelineLayout {
    static let dotSize: CGFloat = 13
    static let trackWidth: CGFloat = 3
    static let dotTopPadding: CGFloat = 14  // space between the top of the card row and the top of the dot
    static let horizontalPadding: CGFloat = 16  // padding applied to each card row

    /// Dot column width (wider than dot for tap area)
    static let dotColumnWidth: CGFloat = dotSize

    /// Vertical offset from card top to dot center
    static let dotCenterY: CGFloat = dotTopPadding + dotSize / 2

    /// Leading offset to center the track on the dot
    static let trackLeading: CGFloat =
        horizontalPadding + dotColumnWidth / 2 - trackWidth / 2

    /// Leading offset for picker to align with card content
    static let pickerLeading: CGFloat =
        horizontalPadding + dotColumnWidth + 10  // 10 = HStack spacing
}

private struct DotPositionKey: PreferenceKey {
    static var defaultValue: [Int: CGFloat] = [:]
    static func reduce(
        value: inout [Int: CGFloat],
        nextValue: () -> [Int: CGFloat]
    ) {
        value.merge(nextValue()) { $1 }
    }
}

struct PhaseListView: View {
    let matchState: MatchState
    let selectedAlliance: Alliance?
    let onAllianceSelected: (Alliance) -> Void
    @Namespace private var activeCard
    @State private var dotPositions: [Int: CGFloat] = [:]

    private let allPhases: [MatchPhase] = [
        MatchPhase.Auto.shared,
        MatchPhase.AutoEndPause.shared,
        MatchPhase.Transition.shared,
        MatchPhase.AllianceShift(number: 1, activeAlliance: nil),
        MatchPhase.AllianceShift(number: 2, activeAlliance: nil),
        MatchPhase.AllianceShift(number: 3, activeAlliance: nil),
        MatchPhase.AllianceShift(number: 4, activeAlliance: nil),
        MatchPhase.Endgame.shared,
        MatchPhase.MatchEnded.shared,
    ]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(allPhases.enumerated()), id: \.offset) {
                index,
                phase in

                let phase = resolvedPhase(for: phase)
                let active = isActive(phase)
                let past = isPast(phase)
                let isLast = index == allPhases.count - 1

                if index == 2 {
                    AlliancePickerView(
                        selectedAlliance: selectedAlliance,
                        onAllianceSelected: onAllianceSelected
                    )
                    .padding(.leading, TimelineLayout.pickerLeading)
                    .padding(.trailing, 16)
                    .padding(.bottom, 4)
                }

                PhaseCardView(
                    phase: phase,
                    isActive: active,
                    isPast: past,
                    phaseSecondsRemaining: active
                        ? matchState.phaseSecondsRemaining : 0,
                    activeNamespace: activeCard
                )
                .padding(.horizontal, 16)
                .padding(.bottom, isLast ? 0 : 6)
                .background {
                    GeometryReader { geo in
                        Color.clear.preference(
                            key: DotPositionKey.self,
                            value: [
                                index: geo.frame(in: .named("timeline")).minY
                                    + TimelineLayout.dotCenterY
                            ]
                        )
                    }
                }
            }
        }
        .padding(.bottom, 32)
        .coordinateSpace(name: "timeline")
        .onPreferenceChange(DotPositionKey.self) { dotPositions = $0 }
        .background(alignment: .topLeading) {
            timelineBackground
                .padding(.leading, TimelineLayout.trackLeading)
        }
    }

    // MARK: - Timeline background

    @ViewBuilder
    private var timelineBackground: some View {
        let firstY = dotPositions[0] ?? 0
        let lastY = dotPositions[allPhases.count - 1] ?? firstY
        let fillHeight = max(0, computeFilledY(firstY: firstY) - firstY)

        if firstY < lastY {
            ZStack(alignment: .top) {
                // Gray track
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(
                        width: TimelineLayout.trackWidth,
                        height: lastY - firstY
                    )

                // Filled progress
                Rectangle()
                    .fill(Color.green)
                    .frame(width: TimelineLayout.trackWidth, height: fillHeight)
                    .animation(
                        .linear(duration: 1.0),
                        value: matchState.totalElapsed
                    )
            }
            .frame(width: TimelineLayout.trackWidth, alignment: .top)
            .padding(.top, firstY)
        }
    }

    private func computeFilledY(firstY: CGFloat) -> CGFloat {
        if matchState.phase is MatchPhase.MatchEnded {
            return dotPositions[allPhases.count - 1] ?? firstY
        }

        let order = phaseOrder(matchState.phase)
        let currentDotY = dotPositions[order] ?? firstY
        let nextDotY = dotPositions[order + 1] ?? currentDotY

        let duration = CGFloat(phaseDuration(for: matchState.phase))
        guard duration > 0 else { return currentDotY }

        let progress =
            1.0 - CGFloat(matchState.phaseSecondsRemaining) / duration
        return currentDotY + (nextDotY - currentDotY) * min(max(progress, 0), 1)
    }

    // MARK: - Helpers

    private func resolvedPhase(for phase: MatchPhase) -> MatchPhase {
        guard let shift = phase as? MatchPhase.AllianceShift else {
            return phase
        }
        guard let lowest = selectedAlliance else { return shift }
        let highest: Alliance = lowest == .red ? .blue : .red
        let active = shift.number % 2 == 1 ? lowest : highest
        return MatchPhase.AllianceShift(
            number: shift.number,
            activeAlliance: active
        )
    }

    private func isActive(_ phase: MatchPhase) -> Bool {
        phaseOrder(matchState.phase) == phaseOrder(phase)
    }

    private func isPast(_ phase: MatchPhase) -> Bool {
        phaseOrder(matchState.phase) > phaseOrder(phase)
    }

    private func phaseOrder(_ phase: MatchPhase) -> Int {
        switch phase {
        case is MatchPhase.Auto: return 0
        case is MatchPhase.AutoEndPause: return 1
        case is MatchPhase.Transition: return 2
        case let s as MatchPhase.AllianceShift: return 2 + Int(s.number)
        case is MatchPhase.Endgame: return 7
        case is MatchPhase.MatchEnded: return 8
        default: return -1
        }
    }

    private func phaseDuration(for phase: MatchPhase) -> Int {
        switch phase {
        case is MatchPhase.Auto: return 20
        case is MatchPhase.AutoEndPause: return 3
        case is MatchPhase.Transition: return 10
        case is MatchPhase.AllianceShift: return 25
        case is MatchPhase.Endgame: return 30
        default: return 0
        }
    }
}
