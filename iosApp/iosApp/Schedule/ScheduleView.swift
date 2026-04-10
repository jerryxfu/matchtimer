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
    @State private var highlightedTeams: [String: Color] = [:]

    var body: some View {
        Group {
            if #available(iOS 17.0, *) {
                scheduleContent
                    .onChange(of: highlightedTeams) { _, _ in
                        // Update Live Activity when highlights change mid-session
                        if let event {
                            Task {
                                await ScheduleLiveActivityManager.shared
                                    .startOrUpdate(
                                        event: event,
                                        highlightedTeams: highlightedTeams
                                    )
                            }
                        }
                    }
            } else {
                // iOS 16 fallback: skip Live Activities
                scheduleContent
            }
        }
        .task {
            await refreshLoop()
        }
    }

    private var scheduleContent: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(spacing: 0) {
                    Color.clear.frame(height: 140)

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
    }

    private func refreshLoop() async {
        while !Task.isCancelled {
            do {
                let newEvent = try await BackendKt.getEventData(
                    eventKey: "2026nvlv"
                )
                event = newEvent
                error = nil

                // Auto-start or update the Live Activity (no dupes)
                if let newEvent {
                    await ScheduleLiveActivityManager.shared.startOrUpdate(
                        event: newEvent,
                        highlightedTeams: highlightedTeams
                    )
                }
            } catch {
                self.error = error.localizedDescription
            }
            try? await Task.sleep(for: .seconds(30))
        }
    }
}
