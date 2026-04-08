import SwiftUI
import ComposeApp

struct PhaseListView: View {
    let matchState: MatchState
    let selectedAlliance: Alliance?
    let onAllianceSelected: (Alliance) -> Void
    @Namespace private var activeCard

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

    private var progress: CGFloat {
        CGFloat(matchState.totalElapsed) / CGFloat(MatchState.companion.MATCH_DURATION)
    }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(allPhases.enumerated()), id: \.offset) { index, phase in

                if index == 2 {
                    AlliancePickerView(
                        selectedAlliance: selectedAlliance,
                        onAllianceSelected: onAllianceSelected
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 6)
                }

                PhaseCardView(
                    phase: resolvedPhase(for: phase),
                    isActive: isActive(phase),
                    isPast: isPast(phase),
                    phaseSecondsRemaining: isActive(phase) ? matchState.phaseSecondsRemaining : 0,
                    isLast: index == allPhases.count - 1,
                    activeNamespace: activeCard
                )
                .padding(.leading, 16)
                .padding(.trailing, 16)
                .padding(.bottom, 6)
            }
        }
        .padding(.bottom, 32)
    }

    private func resolvedPhase(for phase: MatchPhase) -> MatchPhase {
        guard let shift = phase as? MatchPhase.AllianceShift else { return phase }
        guard let lowest = selectedAlliance else { return shift }
        let highest: Alliance = lowest == .red ? .blue : .red
        let active = shift.number % 2 == 1 ? lowest : highest
        return MatchPhase.AllianceShift(number: shift.number, activeAlliance: active)
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

    private func dotColor(for phase: MatchPhase) -> Color {
        isPast(phase) || isActive(phase) ? activeColor(for: phase) : Color(.systemGray4)
    }

    private func activeColor(for phase: MatchPhase) -> Color {
        switch phase {
        case is MatchPhase.Auto: return .green
        case is MatchPhase.AutoEndPause: return Color(.systemGray3)
        case is MatchPhase.Transition: return Color(.systemGray3)
        case is MatchPhase.AllianceShift: return .blue
        case is MatchPhase.Endgame: return .orange
        default: return Color(.systemGray4)
        }
    }
}
