package net.jerryxf.matchtimer

data class MatchState(
    val phase: MatchPhase = MatchPhase.Auto,
    val totalElapsed: Int = 0,
    val phaseSecondsRemaining: Int = 20
) {
    companion object {
        const val MATCH_DURATION = 160

        fun idle() = MatchState(
            phase = MatchPhase.Auto,
            totalElapsed = 0,
            phaseSecondsRemaining = 20
        )

        fun ended() = MatchState(
            phase = MatchPhase.MatchEnded,
            totalElapsed = MATCH_DURATION,
            phaseSecondsRemaining = 0
        )
    }

    val totalSecondsRemaining: Int
        get() = MATCH_DURATION - totalElapsed
}
