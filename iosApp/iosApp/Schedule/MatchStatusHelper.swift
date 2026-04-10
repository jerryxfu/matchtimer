//
//  MatchStatusHelper.swift
//  iosApp
//
//  Created by Jerry Fu on 2026-04-10.
//

import ComposeApp
import Foundation

enum MatchStatusHelper {
    /// A match is "done" when:
    /// - Its status is "On field", AND
    ///   - Another "On field" match has a later start time, OR
    ///   - Its estimated start time + buffer is in the past
    static func isDone(
        _ match: SharedMatch,
        currentOnFieldStart: Int64?
    ) -> Bool {
        guard match.status.lowercased() == "on field" else { return false }

        // Superseded by a newer "On field" match
        if let currentStart = currentOnFieldStart,
            match.times.estimatedStartTime < currentStart
        {
            return true
        }

        // Match start + buffer is in the past
        let matchDurationBufferMs: Int64 = 3 * 60 * 1000
        let estimatedEnd =
            match.times.estimatedStartTime + matchDurationBufferMs
        let nowMs = Int64(Date().timeIntervalSince1970 * 1000)
        return nowMs > estimatedEnd
    }

    /// The "current" on-field start time — the latest start time among
    /// "On field" matches.
    static func currentOnFieldStart(in matches: [SharedMatch]) -> Int64? {
        matches
            .filter { $0.status.lowercased() == "on field" }
            .map { $0.times.estimatedStartTime }
            .max()
    }

    /// The match currently being played (if any).
    static func isCurrentlyPlaying(
        _ match: SharedMatch,
        currentOnFieldStart: Int64?
    ) -> Bool {
        match.status.lowercased() == "on field"
            && match.times.estimatedStartTime == currentOnFieldStart
            && !isDone(match, currentOnFieldStart: currentOnFieldStart)
    }
}
