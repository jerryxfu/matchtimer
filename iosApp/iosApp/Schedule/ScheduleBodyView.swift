//
//  ScheduleView.swift
//  iosApp
//
//  Created by Jerry Fu on 2026-04-09.
//

import ComposeApp
import SwiftUI

struct ScheduleBodyView: View {
    @State private var event: Event?
    @State private var error: String?

    var body: some View {
        NavigationStack {
            Group {
                if let event {
                    List(Array(event.matches.enumerated()), id: \.offset) {
                        _,
                        match in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(match.label)
                                    .font(.headline)
                                Spacer()
                                Text(match.status)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Color(.systemGray6))
                                    .clipShape(
                                        RoundedRectangle(cornerRadius: 6)
                                    )
                            }

                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Red")
                                        .font(.caption2)
                                        .foregroundStyle(.red)
                                    Text(match.redTeams.joined(separator: ", "))
                                        .font(.caption)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Blue")
                                        .font(.caption2)
                                        .foregroundStyle(.blue)
                                    Text(
                                        match.blueTeams.joined(separator: ", ")
                                    )
                                    .font(.caption)
                                }
                            }

                            Text(
                                "Est. start: \(formatEpoch(match.times.estimatedStartTime))"
                            )
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                } else if let error {
                    Text(error)
                        .foregroundStyle(.red)
                } else {
                    ProgressView("Loading schedule...")
                }
            }
            .navigationTitle("Schedule")
        }
        .task {
            do {
                event = try await EventKt.getEventData(eventKey: "demo6885")
            } catch {
                self.error = error.localizedDescription
            }
        }
    }

    private func formatEpoch(_ epoch: Int64) -> String {
        let date = Date(timeIntervalSince1970: Double(epoch))
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
