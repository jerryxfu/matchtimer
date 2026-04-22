import Foundation

enum TimeFormatting {
    /// Format an epoch (in milliseconds) as a short time string like "3:45 PM"
    static func formatTime(_ epochMs: Int64) -> String {
        let date = Date(timeIntervalSince1970: Double(epochMs) / 1000.0)
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    /// Format an epoch (in milliseconds) as a short date+time string
    static func formatDateTime(_ epochMs: Int64) -> String {
        let date = Date(timeIntervalSince1970: Double(epochMs) / 1000.0)
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    /// Relative time description like "in 5m", "in 1h 20m", "3m ago", "now"
    static func relativeTime(_ epochMs: Int64) -> String {
        let date = Date(timeIntervalSince1970: Double(epochMs) / 1000.0)
        let diff = date.timeIntervalSinceNow

        if abs(diff) < 60 {
            return "now"
        }

        let minutes = Int(diff / 60)
        let hours = Int(diff / 3600)

        if diff > 0 {
            if hours > 0 {
                let remainingMin = minutes - hours * 60
                return remainingMin > 0
                    ? "in \(hours)h \(remainingMin)m"
                    : "in \(hours)h"
            }
            return "in \(minutes)m"
        } else {
            if hours < 0 {
                let remainingMin = abs(minutes) - abs(hours) * 60
                return remainingMin > 0
                    ? "\(abs(hours))h \(remainingMin)m ago"
                    : "\(abs(hours))h ago"
            }
            return "\(abs(minutes))m ago"
        }
    }
}
