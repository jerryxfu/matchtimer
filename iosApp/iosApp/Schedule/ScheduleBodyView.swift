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
    @Binding var highlightedTeams: [String: Color]

    var body: some View {
        if let event {
            let currentOnFieldStart: Int64? = event.matches
                .filter { $0.status.lowercased() == "on field" }
                .map { $0.times.estimatedStartTime }
                .max()

            LazyVStack(spacing: 8) {
                HighlightTeamsBar(highlightedTeams: $highlightedTeams)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 4)

                ForEach(Array(event.matches.enumerated()), id: \.offset) {
                    _, match in
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
            errorView(error)
        } else {
            loadingView
        }
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 36))
                .foregroundStyle(.orange)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
    }

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading schedule...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(32)
    }
}
