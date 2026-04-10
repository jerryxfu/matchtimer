//
//  ScheduleView.swift
//  iosApp
//
//  Created by Jerry Fu on 2026-04-09.
//

import ComposeApp
import SwiftUI

struct ScheduleBodyView: View {
    let event: Event?
    let error: String?
    let highlightedTeams: [String: Color]

    var body: some View {
        if let event {
            // Compute which "On field" match is the current one
            // (the one with the latest start time among On field matches)
            let currentOnFieldStart: Int64? = event.matches
                .filter { $0.status.lowercased() == "on field" }
                .map { $0.times.estimatedStartTime }
                .max()

            LazyVStack(spacing: 8) {
                ForEach(Array(event.matches.enumerated()), id: \.offset) {
                    _,
                    match in
                    MatchCardView(
                        match: match,
                        highlightedTeams: highlightedTeams,
                        currentOnFieldStart: currentOnFieldStart
                    )
                    .padding(.horizontal, 16)
                }
            }
            .padding(.bottom, 32)
        } else if let error {
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 36))
                    .foregroundStyle(.orange)
                Text(error)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(32)
        } else {
            VStack(spacing: 12) {
                ProgressView()
                Text("Loading schedule...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(32)
        }
    }
}

// MARK: - Match card

private struct MatchCardView: View {
    let match: Match
    let highlightedTeams: [String: Color]
    let currentOnFieldStart: Int64?
    @ObservedObject private var network = NetworkMonitor.shared

    private var hasHighlightedTeam: Bool {
        match.redTeams.contains { highlightedTeams[$0] != nil }
            || match.blueTeams.contains { highlightedTeams[$0] != nil }
    }

    /// A match is "done" if it's "On field" but an older match than the current one.
    /// The current on-field match is the one with the latest start time.
    private var isDone: Bool {
        match.status.lowercased() == "on field"
            && currentOnFieldStart != nil
            && match.times.estimatedStartTime < currentOnFieldStart!
    }

    /// The match currently being played.
    private var isCurrentlyPlaying: Bool {
        match.status.lowercased() == "on field"
            && match.times.estimatedStartTime == currentOnFieldStart
    }

    private var isActive: Bool {
        let s = match.status.lowercased()
        return isCurrentlyPlaying || s == "on deck" || s == "now queuing"
    }

    private var statusInfo: (text: String, color: Color, icon: String) {
        if isCurrentlyPlaying {
            return ("On field", .green, "flag.fill")
        }
        switch match.status.lowercased() {
        case "on field":
            return ("Done", .gray, "checkmark.circle.fill")
        case "on deck":
            return ("On deck", .blue, "clock.fill")
        case "now queuing":
            return ("Now queuing", .orange, "figure.walk")
        case "queuing soon":
            return ("Queuing soon", .purple, "hourglass")
        default:
            return (match.status, .secondary, "circle")
        }
    }

    var body: some View {
        Group {
            if isDone {
                collapsedView
            } else {
                fullView
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isDone
                        ? Color(.systemGray5)
                        : hasHighlightedTeam
                            ? highlightBorderColor.opacity(0.6)
                            : isActive
                                ? statusInfo.color.opacity(0.4)
                                : Color(.systemGray5),
                    lineWidth: isDone
                        ? 0.5
                        : hasHighlightedTeam ? 2 : isActive ? 1.5 : 0.5
                )
        )
        .shadow(
            color: isDone
                ? .clear
                : hasHighlightedTeam
                    ? highlightBorderColor.opacity(0.15)
                    : isActive ? statusInfo.color.opacity(0.1) : .clear,
            radius: 8,
            y: 2
        )
    }

    // MARK: - Collapsed (done) view

    private var collapsedView: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Line 1: label + time ago
            HStack {
                Text(match.label)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                Text(relativeTime(match.times.estimatedStartTime))
                    .font(.system(size: 11))
                    .foregroundStyle(.tertiary)
            }

            // Line 2: teams (horizontal scroll if needed)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    HStack(spacing: 3) {
                        ForEach(match.redTeams, id: \.self) { team in
                            teamPill(team: team, color: .red, compact: true)
                        }
                    }

                    Text("vs")
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)

                    HStack(spacing: 3) {
                        ForEach(match.blueTeams, id: \.self) { team in
                            teamPill(team: team, color: .blue, compact: true)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .opacity(0.65)
    }

    // MARK: - Full view

    private var fullView: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack {
                Text(match.label)
                    .font(.system(size: 15, weight: .semibold))

                Spacer()

                LiveStatusBadge(
                    text: statusInfo.text,
                    color: statusInfo.color,
                    icon: statusInfo.icon,
                    isLive: network.isConnected && !isDone
                )
            }

            // Teams
            HStack(spacing: 8) {
                teamRow(label: "RED", teams: match.redTeams, color: .red)
                teamRow(label: "BLUE", teams: match.blueTeams, color: .blue)
            }

            // Timings carousel
            TimingCarouselView(times: match.times)
                .padding(8)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(12)
    }

    // MARK: - Team row / pill

    private func teamRow(label: String, teams: [String], color: Color)
        -> some View
    {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                Text(label)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(color.opacity(0.7))
                ForEach(teams, id: \.self) { team in
                    teamPill(team: team, color: color, compact: false)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(5)
        .background(color.opacity(0.03))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(color.opacity(0.12), lineWidth: 1)
        )
    }

    private func teamPill(team: String, color: Color, compact: Bool)
        -> some View
    {
        let highlight: Color? = highlightedTeams[team]
        let fontSize: CGFloat = compact ? 11 : 12
        let hPad: CGFloat = compact ? 5 : 6
        let vPad: CGFloat = compact ? 2 : 3

        return Text(team)
            .font(
                .system(
                    size: fontSize,
                    weight: highlight != nil ? .bold : .medium
                )
            )
            .lineLimit(1)
            .fixedSize()
            .padding(.horizontal, hPad)
            .padding(.vertical, vPad)
            .background(
                (highlight ?? color).opacity(highlight != nil ? 0.25 : 0.05)
            )
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(
                        (highlight ?? color).opacity(
                            highlight != nil ? 0.6 : 0.15
                        ),
                        lineWidth: highlight != nil ? 1.5 : 0.5
                    )
            )
    }

    // MARK: - Helpers

    private var highlightBorderColor: Color {
        for team in match.redTeams + match.blueTeams {
            if let color = highlightedTeams[team] {
                return color
            }
        }
        return .yellow
    }

    private func formatTime(_ epoch: Int64) -> String {
        let date = Date(timeIntervalSince1970: Double(epoch) / 1000.0)
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func relativeTime(_ epoch: Int64) -> String {
        let date = Date(timeIntervalSince1970: Double(epoch) / 1000.0)
        let diff = date.timeIntervalSinceNow

        if abs(diff) < 60 {
            return "now"
        }

        let minutes = Int(diff / 60)
        let hours = Int(diff / 3600)

        if diff > 0 {
            if hours > 0 {
                let remainingMin = minutes - hours * 60
                return remainingMin > 0
                    ? "in \(hours)h \(remainingMin)m"
                    : "in \(hours)h"
            }
            return "in \(minutes)m"
        } else {
            if hours < 0 {
                let remainingMin = abs(minutes) - abs(hours) * 60
                return remainingMin > 0
                    ? "\(abs(hours))h \(remainingMin)m ago"
                    : "\(abs(hours))h ago"
            }
            return "\(abs(minutes))m ago"
        }
    }
}

// MARK: - Timing carousel

private struct TimingCarouselView: View {
    let times: MatchTimes

    @State private var selection: Int = 0

    private struct TimingEntry {
        let label: String
        let epoch: Int64
    }

    private var entries: [TimingEntry] {
        [
            TimingEntry(label: "Queue", epoch: times.estimatedQueueTime),
            TimingEntry(label: "On Deck", epoch: times.estimatedOnDeckTime),
            TimingEntry(label: "On Field", epoch: times.estimatedOnFieldTime),
            TimingEntry(label: "Start", epoch: times.estimatedStartTime),
        ]
    }

    var body: some View {
        HStack(spacing: 8) {
            // Up/down indicators
            HStack(spacing: 2) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 8, weight: .semibold))
                    .foregroundStyle(selection > 0 ? .secondary : .tertiary)
                Image(systemName: "chevron.right")
                    .font(.system(size: 8, weight: .semibold))
                    .foregroundStyle(
                        selection < entries.count - 1 ? .secondary : .tertiary
                    )
            }
            .frame(width: 12)

            // The carousel slot
            TabView(selection: $selection) {
                ForEach(Array(entries.enumerated()), id: \.offset) {
                    index,
                    entry in
                    HStack(spacing: 4) {
                        Text("\(entry.label):")
                            .font(.system(size: 14))

                        Text(relativeTime(entry.epoch))
                            .font(.system(size: 14))

                        Text("(" + formatTime(entry.epoch) + ")")
                            .font(.system(size: 14))

                        Spacer()
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 24)

            // Page dots on the right
            VStack(spacing: 3) {
                ForEach(0..<entries.count, id: \.self) { i in
                    Circle()
                        .fill(
                            selection == i
                                ? Color.primary.opacity(0.6)
                                : Color.secondary.opacity(0.25)
                        )
                        .frame(width: 4, height: 4)
                }
            }
        }
    }

    private func formatTime(_ epoch: Int64) -> String {
        let date = Date(timeIntervalSince1970: Double(epoch) / 1000.0)
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func relativeTime(_ epoch: Int64) -> String {
        let date = Date(timeIntervalSince1970: Double(epoch) / 1000.0)
        let diff = date.timeIntervalSinceNow

        if abs(diff) < 60 {
            return "now"
        }

        let minutes = Int(diff / 60)
        let hours = Int(diff / 3600)

        if diff > 0 {
            if hours > 0 {
                let remainingMin = minutes - hours * 60
                return remainingMin > 0
                    ? "in \(hours)h \(remainingMin)m"
                    : "in \(hours)h"
            }
            return "in \(minutes)m"
        } else {
            if hours < 0 {
                let remainingMin = abs(minutes) - abs(hours) * 60
                return remainingMin > 0
                    ? "\(abs(hours))h \(remainingMin)m ago"
                    : "\(abs(hours))h ago"
            }
            return "\(abs(minutes))m ago"
        }
    }
}
