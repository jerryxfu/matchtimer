import ComposeApp
import SwiftUI

struct TimelineProgressView: View {
    let dotPositions: [Int: CGFloat]  // phaseOrder -> Y in coordinate space
    let matchState: MatchState
    let phaseCount: Int

    var body: some View {
        let firstY = dotPositions[0] ?? 0
        let lastY = dotPositions[phaseCount - 1] ?? firstY

        Canvas { context, _ in
            // Gray track from first dot to last dot
            let trackPath = Path { p in
                p.move(to: CGPoint(x: 0, y: firstY))
                p.addLine(to: CGPoint(x: 0, y: lastY))
            }
            context.stroke(
                trackPath,
                with: .color(Color(.systemGray5)),
                lineWidth: 2
            )

            // Filled progress
            let filledY = computeFilledY(firstY: firstY, lastY: lastY)
            if filledY > firstY {
                let fillPath = Path { p in
                    p.move(to: CGPoint(x: 0, y: firstY))
                    p.addLine(to: CGPoint(x: 0, y: filledY))
                }
                context.stroke(
                    fillPath,
                    with: .color(.blue),
                    lineWidth: 2
                )
            }
        }
        .animation(.linear(duration: 1.0), value: matchState.totalElapsed)
        .frame(width: 2)
    }

    private func computeFilledY(firstY: CGFloat, lastY: CGFloat) -> CGFloat {
        if matchState.phase is MatchPhase.MatchEnded {
            return lastY
        }

        let order = phaseOrder(matchState.phase)
        let currentDotY = dotPositions[order] ?? firstY
        let nextDotY = dotPositions[order + 1] ?? currentDotY

        let duration = CGFloat(phaseDuration(for: matchState.phase))
        let progress: CGFloat =
            duration > 0
            ? 1.0 - CGFloat(matchState.phaseSecondsRemaining) / duration
            : 0

        return currentDotY + (nextDotY - currentDotY) * min(max(progress, 0), 1)
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
