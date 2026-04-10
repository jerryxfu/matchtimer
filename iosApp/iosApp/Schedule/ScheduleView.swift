//
//  ScheduleView.swift
//  iosApp
//
//  Created by Jerry Fu on 2026-04-09.
//

import ComposeApp
import SwiftUI

struct ScheduleView: View {
    @State private var event: Event?
    @State private var error: String?
    @State private var highlightedTeams: [String: Color] = [:]

    var body: some View {
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
        .task {
            await refreshLoop()
        }
    }

    private func refreshLoop() async {
        while !Task.isCancelled {
            do {
                event = try await EventKt.getEventData(eventKey: "demo1815")
                error = nil
            } catch {
                self.error = error.localizedDescription
            }
            try? await Task.sleep(for: .seconds(30))
        }
    }
}
