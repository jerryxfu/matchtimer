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
    private var backgroundTask: Task<Void, Never>?
    private var matchStartDate: Date?
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
        let isEnded = matchState.phase is MatchPhase.MatchEnded
        if isEnded { reset() }
        guard collectionTask == nil else { return }

        matchStartDate = Date()
        startLiveActivity()

        collectionTask = Task {
            for await state in timer.matchState {
                matchState = state
                updateLiveActivity(state: state)

                if state.phase is MatchPhase.MatchEnded {
                    endLiveActivity()
                }
            }
        }
        timer.start(scope: CoroutineHelperKt.createMainScope())
    }

    func stop() {
        timer.stop()
        collectionTask?.cancel()
        collectionTask = nil
        backgroundTask?.cancel()
        backgroundTask = nil
        matchStartDate = nil
        endLiveActivity()
    }

    func reset() {
        timer.reset()
        collectionTask?.cancel()
        collectionTask = nil
        backgroundTask?.cancel()
        backgroundTask = nil
        matchStartDate = nil
        lowestAutoAlliance = nil
        endLiveActivity()
    }

    @Published var lowestAutoAlliance: Alliance? = nil

    func setLowestAlliance(_ alliance: Alliance) {
        timer.lowestAutoAlliance = alliance
        lowestAutoAlliance = alliance
    }

    // MARK: - Background / Foreground

    private func onBackground() {
        guard let startDate = matchStartDate,
            !(matchState.phase is MatchPhase.MatchEnded)
        else { return }

        backgroundTask = Task {
            let elapsed = Date().timeIntervalSince(startDate)
            let transitions = Self.phaseTransitions(
                lowestAlliance: lowestAutoAlliance
            )

            for transition in transitions {
                let fireAt = transition.startTime - elapsed
                if fireAt <= 0 { continue }

                try? await Task.sleep(for: .seconds(fireAt))
                if Task.isCancelled { return }

                guard let activity = currentActivity else { return }
                let state = MatchActivityAttributes.ContentState(
                    phaseName: transition.name,
                    phaseSubtitle: transition.subtitle,
                    phaseSecondsRemaining: transition.duration,
                    phaseDuration: transition.duration,
                    totalSecondsRemaining: 160 - Int(transition.startTime),
                    activeAllianceName: transition.activeAlliance,
                    isMatchEnded: false
                )
                await activity.update(.init(state: state, staleDate: nil))
            }

            let matchEndIn = 160.0 - elapsed
            if matchEndIn > 0 {
                try? await Task.sleep(for: .seconds(matchEndIn))
                if Task.isCancelled { return }
                endLiveActivity()
            }
        }
    }

    private func onForeground() {
        backgroundTask?.cancel()
        backgroundTask = nil
    }

    // MARK: - Phase schedule

    private struct PhaseTransition {
        let name: String
        let subtitle: String
        let duration: Int
        let startTime: Double
        let activeAlliance: String?
    }

    private static func phaseTransitions(
        lowestAlliance: Alliance?
    ) -> [PhaseTransition] {
        var transitions: [PhaseTransition] = []
        var t: Double = 0

        transitions.append(
            PhaseTransition(
                name: "Autonomous",
                subtitle: "Both hubs active",
                duration: 20,
                startTime: t,
                activeAlliance: nil
            )
        )
        t += 20

        transitions.append(
            PhaseTransition(
                name: "Auto end pause",
                subtitle: "Piece counting delay",
                duration: 3,
                startTime: t,
                activeAlliance: nil
            )
        )
        t += 3

        transitions.append(
            PhaseTransition(
                name: "Transition",
                subtitle: "Both hubs active",
                duration: 10,
                startTime: t,
                activeAlliance: nil
            )
        )
        t += 10

        for i in 1...4 {
            let alliance: String?
            if let lowest = lowestAlliance {
                let lowestName = lowest == .red ? "Red" : "Blue"
                let highestName = lowest == .red ? "Blue" : "Red"
                alliance = i % 2 == 1 ? lowestName : highestName
            } else {
                alliance = nil
            }
            transitions.append(
                PhaseTransition(
                    name: "Alliance shift \(i)",
                    subtitle: "Hub flip · teleop",
                    duration: 25,
                    startTime: t,
                    activeAlliance: alliance
                )
            )
            t += 25
        }

        transitions.append(
            PhaseTransition(
                name: "Endgame",
                subtitle: "Both hubs active · climb",
                duration: 30,
                startTime: t,
                activeAlliance: nil
            )
        )

        return transitions
    }

    // MARK: - Live Activity

    private func startLiveActivity() {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let attributes = MatchActivityAttributes()
        let initialState = MatchActivityAttributes.ContentState(
            phaseName: "Autonomous",
            phaseSubtitle: "Both hubs active",
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
            phaseSubtitle: phaseSubtitle(for: state.phase),
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
            phaseSubtitle: "",
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

    private func phaseSubtitle(for phase: MatchPhase) -> String {
        switch phase {
//        case is MatchPhase.Auto: return "Both hubs active"
//        case is MatchPhase.AutoEndPause: return "Piece counting delay"
//        case is MatchPhase.Transition: return "Both hubs active"
//        case is MatchPhase.AllianceShift: return "Hub flip · teleop"
//        case is MatchPhase.Endgame: return "Both hubs active · climb"
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
