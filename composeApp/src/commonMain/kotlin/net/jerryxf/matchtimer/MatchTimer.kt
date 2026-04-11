package net.jerryxf.matchtimer

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import kotlin.time.Duration.Companion.milliseconds

class MatchTimer(var lowestAutoAlliance: Alliance? = null) {
    private fun highestAutoAlliance() =
        if (lowestAutoAlliance == Alliance.RED) Alliance.BLUE else Alliance.RED

    private fun activeAllianceFor(shiftNumber: Int): Alliance? {
        return lowestAutoAlliance?.let {
            if (shiftNumber % 2 == 1) it else highestAutoAlliance()
        }
    }

    private val phases = listOf(
        MatchPhase.Auto to 20,
        MatchPhase.AutoEndPause to 3,
        MatchPhase.Transition to 10,
        MatchPhase.AllianceShift(1, null) to 25,
        MatchPhase.AllianceShift(2, null) to 25,
        MatchPhase.AllianceShift(3, null) to 25,
        MatchPhase.AllianceShift(4, null) to 25,
        MatchPhase.Endgame to 30,
    )

    private val _matchState = MutableStateFlow(MatchState.idle())
    val matchState: StateFlow<MatchState> = _matchState

    private var job: Job? = null

    fun start(scope: CoroutineScope) {
        if (job?.isActive == true) return
        var totalElapsed = 0
        job = scope.launch {
            for ((phase, duration) in phases) {
                var remainingDuration = duration
                while (remainingDuration > 0) {
                    val currentPhase = when (phase) {
                        is MatchPhase.AllianceShift -> phase.copy(
                            activeAlliance = activeAllianceFor(phase.number)
                        )

                        else -> phase
                    }
                    _matchState.value = MatchState(currentPhase, totalElapsed, remainingDuration)
                    delay(1000.milliseconds)
                    remainingDuration--
                    if (phase !is MatchPhase.AutoEndPause) totalElapsed++
                }
            }
            _matchState.value = MatchState.ended()
        }
    }

    fun reset() {
        job?.cancel()
        job = null
        _matchState.value = MatchState()
    }

    fun stop() {
        job?.cancel()
    }
}
