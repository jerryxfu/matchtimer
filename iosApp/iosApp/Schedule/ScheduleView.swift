//
//  ScheduleView.swift
//  iosApp
//
//  Created by Jerry Fu on 2026-04-09.
//

import ComposeApp
import SwiftUI

struct ScheduleView: View {
    @State private var event: SharedEvent?
    @State private var error: String?
    @State private var highlightedTeams: [String: Color] = [
        "3990": .yellow,
        "9406": .purple,
    ]

    var body: some View {
        if #available(iOS 17.0, *) {
            ZStack(alignment: .top) {
                ScrollView {
                    VStack(spacing: 0) {
                        Color.clear.frame(height: 135)

                        ScheduleBodyView(
                            event: event,
                            error: error,
                            highlightedTeams: $highlightedTeams
                        )
                    }
                }

                ScheduleHeaderView(event: event)
                    .background(.ultraThinMaterial)
            }
            .ignoresSafeArea(edges: .top)
            .task {
                await refreshLoop()
            }
            .onChange(of: highlightedTeams) { _, _ in
                updateLiveActivityForHighlights()
            }
        } else {
            ZStack(alignment: .top) {
                ScrollView {
                    VStack(spacing: 0) {
                        Color.clear.frame(height: 120)

                        ScheduleBodyView(
                            event: event,
                            error: error,
                            highlightedTeams: $highlightedTeams
                        )
                    }
                }

                ScheduleHeaderView(event: event)
                    .background(.ultraThinMaterial)
            }
            .ignoresSafeArea(edges: .top)
            .task {
                await refreshLoop()
            }
            .onChange(of: highlightedTeams) { _ in
                updateLiveActivityForHighlights()
            }
        }
    }

    private func updateLiveActivityForHighlights() {
        // Keep the Live Activity in sync when highlighted teams change.
        if let event {
            Task {
                await ScheduleLiveActivityManager.shared.startOrUpdate(
                    event: event,
                    highlightedTeams: highlightedTeams
                )
            }
        }
    }

    private func refreshLoop() async {
        while !Task.isCancelled {
            do {
                let newEvent = try await BackendKt.getEventData(
                    eventKey: "2026nvlv"
                )
                event = newEvent
                error = nil

                // Auto-start or update the Live Activity (never creates dupes)
                if let newEvent {
                    await ScheduleLiveActivityManager.shared.startOrUpdate(
                        event: newEvent,
                        highlightedTeams: highlightedTeams
                    )
                }
            } catch {
                self.error = error.localizedDescription
            }
            try? await Task.sleep(for: .seconds(15))
        }
    }
}
