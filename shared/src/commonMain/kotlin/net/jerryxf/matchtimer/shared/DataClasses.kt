package net.jerryxf.matchtimer.shared

import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json

val jsonConfig = Json {
    ignoreUnknownKeys = true
    explicitNulls = false
}

@Serializable
data class Event(
    val eventKey: String,
    val dataAsOfTime: Long,
    val matches: List<Match>
)

@Serializable
data class Match(
    val label: String,
    val status: String,
    val breakAfter: String?,
    val redTeams: List<String?>?,
    val blueTeams: List<String?>?,
    val times: MatchTimes
)

@Serializable
data class MatchTimes(
    val estimatedQueueTime: Long?,
    val estimatedOnDeckTime: Long?,
    val estimatedOnFieldTime: Long,
    val estimatedStartTime: Long
)

@Serializable
data class MatchScore(
    val blue: UShort,
    val red: UShort
)
