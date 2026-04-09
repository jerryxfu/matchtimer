package net.jerryxf.matchtimer

sealed class MatchPhase {
    object Auto : MatchPhase()
    object AutoEndPause : MatchPhase()  // 3s, clock frozen at 2:20
    object Transition : MatchPhase()
    data class AllianceShift(val number: Int, val activeAlliance: Alliance?) : MatchPhase()
    object Endgame : MatchPhase()
    object MatchEnded : MatchPhase()
}
