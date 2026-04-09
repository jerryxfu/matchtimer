//
//  MatchActivityAttributes.swift
//  iosApp
//
//  Created by Jerry Fu on 2026-04-08.
//

import ActivityKit
import Foundation

struct MatchActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var phaseName: String
        var phaseSubtitle: String
        var phaseSecondsRemaining: Int
        var phaseDuration: Int
        var totalSecondsRemaining: Int
        var activeAllianceName: String?
        var isMatchEnded: Bool
    }
}
