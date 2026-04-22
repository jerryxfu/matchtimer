import ActivityKit
import Foundation

struct MatchActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var phaseName: String
        var phaseSecondsRemaining: Int
        var phaseDuration: Int
        var totalSecondsRemaining: Int
        var activeAllianceName: String?
        var isMatchEnded: Bool
    }
}
