//
//  TimingCarouselView.swift
//  iosApp
//
//  Created by Jerry Fu on 2026-04-10.
//

import ComposeApp
import SwiftUI

struct TimingCarouselView: View {
    let times: MatchTimes

    @State private var selection: Int = 0
    @State private var hasInitialized = false

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

    /// Index of the next upcoming timing (or last one if all have passed)
    private var nextUpcomingIndex: Int {
        let now = Date().timeIntervalSince1970 * 1000
        if let idx = entries.firstIndex(where: { Double($0.epoch) > now }) {
            return idx
        }
        return entries.count - 1
    }

    var body: some View {
        HStack(spacing: 8) {
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

            TabView(selection: $selection) {
                ForEach(Array(entries.enumerated()), id: \.offset) {
                    index,
                    entry in
                    HStack(spacing: 4) {
                        Text("\(entry.label):")
                            .font(.system(size: 14))

                        Text(TimeFormatting.relativeTime(entry.epoch))
                            .font(.system(size: 14))

                        Text("(" + TimeFormatting.formatTime(entry.epoch) + ")")
                            .font(.system(size: 14))

                        Spacer()
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 24)

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
        .onAppear {
            if !hasInitialized {
                selection = nextUpcomingIndex
                hasInitialized = true
            }
        }
    }
}
