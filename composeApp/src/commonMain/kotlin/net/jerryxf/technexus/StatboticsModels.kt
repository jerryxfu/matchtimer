package net.jerryxf.technexus.statbotics

data class EpaStats(
    val total: Double,
    val auto: Double,
    val teleop: Double,
    val endgame: Double,
)

data class NormEpa(
    val current: Double,
    val recent: Double,
    val mean: Double,
    val max: Double,
)

data class WinRecord(
    val wins: Int,
    val losses: Int,
    val ties: Int,
    val count: Int,
    val winrate: Double,
)

data class StatboticsTeam(
    val team: Int,
    val name: String,
    val country: String?,
    val state: String?,
    val district: String?,
    val rookieYear: Int,
    val active: Boolean,
    val record: WinRecord,
    val normEpa: NormEpa,
)

data class StatboticsTeamYear(
    val team: Int,
    val year: Int,
    val name: String,
    val record: WinRecord,
    val epa: EpaStats,
    val normEpa: NormEpa,
    val rankingPoints: Double?,
    val unitlessEpa: Double,
)

data class StatboticsEvent(
    val key: String,
    val year: Int,
    val name: String,
    val country: String?,
    val state: String?,
    val district: String?,
    val teams: Int,
)

data class StatboticsTeamEvents(
    val team: Int,
    val year: Int,
    val eventKey: String,
    val eventName: String,
    val record: WinRecord,
    val rank: Int?,
    val epa: EpaStats,
    val normEpa: Double?,
)

data class StatboticsMatch(
   val key: String,
    val year: Int,
    val eventKey: String,
    val compLevel: String,
    val setNumber: Int,
    val matchNumber: Int,
    val redTeams: List<Int>,
    val blueTeams: List<Int>,
    val redScore: Int?,
    val blueScore: Int?,
    val winner: Alliance?,
    val redEpaSum: Double?,
    val blueEpaSum: Double?,
    val predictedWinner: Alliance?,
    val winProb: Double?,
)

data class MatchPrediction(
    val matchKey: String,
    val predictedWinner: Alliance,
    val redWinProb: Double,
    val blueWinProb: Double,
    val redEpaSum: Double,
    val blueEpaSum: Double,
)

data class StatboticsYear(
    val year: Int,
    val epaMean: Double,
    val epaStd: Double,
    val epaMax: Double,
    val dominance: Double?,
    val numTeams: Int,
    val numEvents: Int,
    val numMatches: Int,
)

sealed class StatboticsError : Exception() {
    data class NetworkError(override val message: String) : StatboticsError()
    data class NotFound(val resource: String) : StatboticsError()
    data class ParseError(override val cause: Throwable) : StatboticsError()
    data object RateLimited : StatboticsError()
}
