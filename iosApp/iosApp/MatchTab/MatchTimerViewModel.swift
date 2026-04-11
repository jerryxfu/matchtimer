//
//  MatchTimerViewModel.swift
//  iosApp
//
//  Created by Jerry Fu on 2026-04-07.
//

import ActivityKit
import Combine
import ComposeApp
import SwiftUI

@MainActor
class MatchTimerViewModel: ObservableObject {
    private let timer = MatchTimer(lowestAutoAlliance: nil)

    @Published var matchState: MatchState = MatchState.companion.idle()

    private var collectionTask: Task<Void, Never>?
    private var currentActivity: Activity<MatchActivityAttributes>?
    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
    private var cancellables = Set<AnyCancellable>()

    init() {
        NotificationCenter.default.publisher(
            for: UIApplication.willResignActiveNotification
        )
        .sink { [weak self] _ in self?.onBackground() }
        .store(in: &cancellables)

        NotificationCenter.default.publisher(
            for: UIApplication.didBecomeActiveNotification
        )
        .sink { [weak self] _ in self?.onForeground() }
        .store(in: &cancellables)
    }

    func start() {
        print(
            "Activities enabled: \(ActivityAuthorizationInfo().areActivitiesEnabled)"
        )
        print(
            "Existing activities: \(Activity<MatchActivityAttributes>.activities.count)"
        )
        let isEnded = matchState.phase is MatchPhase.MatchEnded
        if isEnded { reset() }
        guard collectionTask == nil else { return }

        startLiveActivity()

        collectionTask = Task {
            for await state in timer.matchState {
                matchState = state
                updateLiveActivity(state: state)

                if state.phase is MatchPhase.MatchEnded {
                    endLiveActivity()
                    endBackgroundTask()
                }
            }
        }
        timer.start(scope: CoroutineHelperKt.createMainScope())
    }

    func stop() {
        timer.stop()
        collectionTask?.cancel()
        collectionTask = nil
        endBackgroundTask()
        endLiveActivity()
    }

    func reset() {
        timer.reset()
        collectionTask?.cancel()
        collectionTask = nil
        lowestAutoAlliance = nil
        endBackgroundTask()
        endLiveActivity()
    }

    @Published var lowestAutoAlliance: Alliance? = nil

    func setLowestAlliance(_ alliance: Alliance) {
        timer.lowestAutoAlliance = alliance
        lowestAutoAlliance = alliance
    }

    // MARK: - Background / Foreground

    private func onBackground() {
        // Only request background time if a match is running
        guard collectionTask != nil,
            !(matchState.phase is MatchPhase.MatchEnded)
        else { return }

        // Request up to ~3 minutes of background execution
        // A full match is 2:40, so this covers it
        backgroundTaskID = UIApplication.shared.beginBackgroundTask {
            // Expiration handler — OS is about to kill us
            self.endBackgroundTask()
        }
    }

    private func onForeground() {
        endBackgroundTask()
    }

    private func endBackgroundTask() {
        if backgroundTaskID != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
            backgroundTaskID = .invalid
        }
    }

    // MARK: - Live Activity

    private func startLiveActivity() {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        // Adopt an existing activity if one is already running
        if let existing = Activity<MatchActivityAttributes>.activities.first {
            currentActivity = existing
            return
        }

        let attributes = MatchActivityAttributes()
        let initialState = MatchActivityAttributes.ContentState(
            phaseName: "Autonomous",
            phaseSecondsRemaining: 20,
            phaseDuration: 20,
            totalSecondsRemaining: 160,
            activeAllianceName: nil,
            isMatchEnded: false
        )

        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                content: .init(state: initialState, staleDate: nil),
                pushType: nil
            )
        } catch {
            print("Failed to start Live Activity: \(error)")
        }
    }

    private func updateLiveActivity(state: MatchState) {
        guard let activity = currentActivity else { return }

        let contentState = MatchActivityAttributes.ContentState(
            phaseName: phaseName(for: state.phase),
            phaseSecondsRemaining: Int(state.phaseSecondsRemaining),
            phaseDuration: phaseDuration(for: state.phase),
            totalSecondsRemaining: Int(state.totalSecondsRemaining),
            activeAllianceName: activeAllianceName(for: state.phase),
            isMatchEnded: state.phase is MatchPhase.MatchEnded
        )

        Task {
            await activity.update(.init(state: contentState, staleDate: nil))
        }
    }

    private func endLiveActivity() {
        guard let activity = currentActivity else { return }

        let finalState = MatchActivityAttributes.ContentState(
            phaseName: "Match over",
            phaseSecondsRemaining: 0,
            phaseDuration: 0,
            totalSecondsRemaining: 0,
            activeAllianceName: nil,
            isMatchEnded: true
        )

        Task {
            await activity.end(
                .init(state: finalState, staleDate: nil),
                dismissalPolicy: .after(.now + 30)
            )
        }
        currentActivity = nil
    }

    // MARK: - Helpers

    private func phaseName(for phase: MatchPhase) -> String {
        switch phase {
        case is MatchPhase.Auto: return "Autonomous"
        case is MatchPhase.AutoEndPause: return "Auto end pause"
        case is MatchPhase.Transition: return "Transition"
        case let s as MatchPhase.AllianceShift:
            return "Alliance shift \(s.number)"
        case is MatchPhase.Endgame: return "Endgame"
        case is MatchPhase.MatchEnded: return "Match over"
        default: return ""
        }
    }

    private func phaseDuration(for phase: MatchPhase) -> Int {
        switch phase {
        case is MatchPhase.Auto: return 20
        case is MatchPhase.AutoEndPause: return 3
        case is MatchPhase.Transition: return 10
        case is MatchPhase.AllianceShift: return 25
        case is MatchPhase.Endgame: return 30
        default: return 0
        }
    }

    private func activeAllianceName(for phase: MatchPhase) -> String? {
        guard let shift = phase as? MatchPhase.AllianceShift,
            let alliance = shift.activeAlliance
        else { return nil }
        return alliance == .red ? "Red" : "Blue"
    }
}
