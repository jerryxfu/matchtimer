//
//  MatchLiveActivityWidget.swift
//  MatchTimer
//
//  Created by Jerry Fu on 2026-04-08.
//

import ActivityKit
import SwiftUI
import WidgetKit

struct MatchTimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MatchActivityAttributes.self) { context in
            LockScreenMatchView(state: context.state)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(context.state.phaseName)
                            .font(.caption)
                            .fontWeight(.semibold)
                        Text(context.state.phaseSubtitle)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        if let alliance = context.state.activeAllianceName {
                            Text(alliance)
                                .font(.caption2)
                                .foregroundStyle(
                                    alliance == "Red" ? Color.red : Color.blue
                                )
                        }
                    }
                }

                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(
                            timerInterval: timerRange(
                                remaining: context.state.totalSecondsRemaining
                            ),
                            countsDown: true
                        )
                        .font(.system(.title3, design: .monospaced))
                        .fontWeight(.semibold)
                        .monospacedDigit()

                        Text("\(context.state.phaseSecondsRemaining)s left")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                DynamicIslandExpandedRegion(.bottom) {
                    VStack {
                        ProgressView(
                            value: phaseProgress(state: context.state),
                            total: 1.0
                        )
                        .tint(phaseColor(name: context.state.phaseName))
                    }
                    .padding(.top, 4)
                }
            } compactLeading: {
                Text(compactPhaseName(context.state.phaseName))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(phaseColor(name: context.state.phaseName))
            } compactTrailing: {
                Text(
                    timerInterval: timerRange(
                        remaining: context.state.totalSecondsRemaining
                    ),
                    countsDown: true
                )
                .font(.system(.caption, design: .monospaced))
                .fontWeight(.semibold)
                .monospacedDigit()
            } minimal: {
                Text(formatTime(context.state.totalSecondsRemaining))
                    .font(.system(.caption2, design: .monospaced))
                    .monospacedDigit()
            }
        }
    }

    // MARK: - Helpers

    private func timerRange(remaining: Int) -> ClosedRange<Date> {
        let now = Date.now
        let end = now.addingTimeInterval(Double(max(remaining, 0)))
        return now...end
    }

    private func phaseProgress(state: MatchActivityAttributes.ContentState)
        -> Double
    {
        guard state.phaseDuration > 0 else { return 0 }
        return 1.0 - Double(state.phaseSecondsRemaining)
            / Double(
                state.phaseDuration
            )
    }

    private func phaseColor(name: String) -> Color {
        switch name {
        case "Autonomous": return .green
        case "Auto end pause", "Transition": return .gray
        case "Endgame": return .orange
        case _ where name.hasPrefix("Alliance shift"): return .blue
        default: return .gray
        }
    }

    private func compactPhaseName(_ name: String) -> String {
        switch name {
        case "Autonomous": return "AUTO"
        case "Auto end pause": return "PAUSE"
        case "Transition": return "TRANS"
        case "Endgame": return "END"
        case _ where name.hasPrefix("Alliance shift"):
            let num = name.last.map(String.init) ?? ""
            return "S\(num)"
        default: return "—"
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
}

// MARK: - Lock screen view

private struct LockScreenMatchView: View {
    let state: MatchActivityAttributes.ContentState

    private var matchProgress: Double {
        let elapsed = 160 - state.totalSecondsRemaining
        return min(Double(elapsed) / 160.0, 1.0)
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(state.phaseName)
                        .font(.headline)
                    Text(state.phaseSubtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if let alliance = state.activeAllianceName {
                        Text("\(alliance) hub active")
                            .font(.caption)
                            .foregroundStyle(
                                alliance == "Red" ? Color.red : Color.blue
                            )
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(formatTime(state.totalSecondsRemaining))
                        .font(.system(.title, design: .monospaced))
                        .fontWeight(.bold)
                        .monospacedDigit()
                    Text("\(state.phaseSecondsRemaining)s left")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            ProgressView(value: matchProgress, total: 1.0)
                .tint(phaseColor(name: state.phaseName))
        }
        .padding(16)
    }

    private func phaseColor(name: String) -> Color {
        switch name {
        case "Autonomous": return .green
        case "Auto end pause", "Transition": return .gray
        case "Endgame": return .orange
        case _ where name.hasPrefix("Alliance shift"): return .blue
        default: return .gray
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
}
