//
//  MatchTimerViewModel.swift
//  iosApp
//
//  Created by Jerry Fu on 2026-04-07.
//


import ComposeApp
import SwiftUI

@MainActor
class MatchTimerViewModel: ObservableObject {
    private let timer = MatchTimer(lowestAutoAlliance: nil)
    
    @Published var matchState: MatchState = MatchState.companion.idle()
    
    private var collectionTask: Task<Void, Never>?
    
    func start() {
        let isEnded = matchState.phase is MatchPhase.MatchEnded
        if isEnded { reset() }
        guard collectionTask == nil else { return }
        collectionTask = Task {
            for await state in timer.matchState {
                matchState = state
            }
        }
        timer.start(scope: CoroutineHelperKt.createMainScope())
    }
    
    func stop() {
        timer.stop()
        collectionTask?.cancel()
    }
    
    func reset() {
        timer.reset()
        collectionTask?.cancel()
        collectionTask = nil
        lowestAutoAlliance = nil
    }
    
    @Published var lowestAutoAlliance: Alliance? = nil

    func setLowestAlliance(_ alliance: Alliance) {
        timer.lowestAutoAlliance = alliance
        lowestAutoAlliance = alliance
    }
}
