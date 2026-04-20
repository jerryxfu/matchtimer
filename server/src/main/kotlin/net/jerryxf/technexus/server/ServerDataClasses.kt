package net.jerryxf.technexus.server

import kotlinx.serialization.Serializable

@Serializable
data class TBAMatch(
    val alliances: TBAAlliances
)

@Serializable
data class TBAAlliances(
    val red: TBAAlliance,
    val blue: TBAAlliance,
)

@Serializable
data class TBAAlliance(
    val score: UShort
)
