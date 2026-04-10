package net.jerryxf.matchtimer.backend

import kotlinx.serialization.Serializable

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
    val redTeams: List<String?>,
    val blueTeams: List<String?>,
    val times: MatchTimes
)

@Serializable
data class MatchTimes(
    val estimatedQueueTime: Long,
    val estimatedOnDeckTime: Long,
    val estimatedOnFieldTime: Long,
    val estimatedStartTime: Long
)
