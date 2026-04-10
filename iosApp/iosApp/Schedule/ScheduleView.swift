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
    @State private var showingTeamEntry = false
    @State private var newTeamNumber = ""
    @State private var selectedColor: Color = .yellow

    private let highlightColors: [Color] = [
        .yellow, .green, .orange, .pink, .cyan, .purple,
    ]

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(spacing: 0) {
                    Color.clear.frame(height: 140)

                    // Highlighted teams bar
                    if !highlightedTeams.isEmpty || showingTeamEntry {
                        highlightBar
                            .padding(.horizontal, 16)
                            .padding(.bottom, 8)
                    }

                    ScheduleBodyView(
                        event: event,
                        error: error,
                        highlightedTeams: highlightedTeams
                    )
                }
            }

            ScheduleHeaderView(event: event)
                .background(.ultraThinMaterial)
        }
        .ignoresSafeArea(edges: .top)
        .overlay(alignment: .bottomTrailing) {
            Button {
                showingTeamEntry.toggle()
            } label: {
                Image(systemName: showingTeamEntry ? "xmark" : "plus")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
            .padding(.trailing, 16)
            .padding(.bottom, 100)
        }
        .task {
            do {
                event = try await EventKt.getEventData(eventKey: "demo1815")
            } catch {
                self.error = error.localizedDescription
            }
        }
    }

    private var highlightBar: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Existing highlights
            if !highlightedTeams.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(
                            highlightedTeams.sorted(by: { $0.key < $1.key }),
                            id: \.key
                        ) { pair in
                            let team = pair.key
                            let teamColor: Color = pair.value
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(teamColor)
                                    .frame(width: 8, height: 8)
                                Text(team)
                                    .font(.system(size: 12, weight: .medium))
                                Button {
                                    withAnimation {
                                        _ = highlightedTeams.removeValue(
                                            forKey: team
                                        )
                                    }
                                } label: {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(teamColor.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
            }

            // Entry row
            if showingTeamEntry {
                HStack(spacing: 8) {
                    TextField("Team #", text: $newTeamNumber)
                        .font(.system(size: 13))
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 80)

                    // Color picker
                    ForEach(highlightColors, id: \.self) { color in
                        Circle()
                            .fill(color)
                            .frame(width: 22, height: 22)
                            .overlay(
                                Circle()
                                    .stroke(
                                        Color.primary,
                                        lineWidth: selectedColor == color
                                            ? 2 : 0
                                    )
                            )
                            .onTapGesture { selectedColor = color }
                    }

                    Spacer()

                    Button("Add") {
                        let trimmed = newTeamNumber.trimmingCharacters(
                            in: .whitespaces
                        )
                        guard !trimmed.isEmpty else { return }
                        withAnimation {
                            highlightedTeams[trimmed] = selectedColor
                        }
                        newTeamNumber = ""
                    }
                    .font(.system(size: 13, weight: .medium))
                    .disabled(
                        newTeamNumber.trimmingCharacters(in: .whitespaces)
                            .isEmpty
                    )
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(10)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray5), lineWidth: 0.5)
        )
    }
}
