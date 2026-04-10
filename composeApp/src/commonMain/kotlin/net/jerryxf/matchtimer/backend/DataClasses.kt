package net.jerryxf.matchtimer.backend

import kotlinx.serialization.KSerializer
import kotlinx.serialization.Serializable
import kotlinx.serialization.descriptors.PrimitiveKind
import kotlinx.serialization.descriptors.PrimitiveSerialDescriptor
import kotlinx.serialization.encoding.Decoder
import kotlinx.serialization.encoding.Encoder
import kotlin.time.Instant


object EpochSecondsInstantSerializer : KSerializer<Instant> {
    override val descriptor = PrimitiveSerialDescriptor("Instant", PrimitiveKind.LONG)
    override fun serialize(encoder: Encoder, value: Instant) = encoder.encodeLong(value.epochSeconds)
    override fun deserialize(decoder: Decoder) = Instant.fromEpochSeconds(decoder.decodeLong())
}

@Serializable
data class Event(
    val eventKey: String,
    @Serializable(with = EpochSecondsInstantSerializer::class)
    val dataAsOfTime: Instant,
    val matches: List<Match>
)

@Serializable
data class Match(
    val label: String,
    val status: String,
    val redTeams: List<String>,
    val blueTeams: List<String>,
    val times: MatchTimes
)

@Serializable
data class MatchTimes(
    @Serializable(with = EpochSecondsInstantSerializer::class)
    val estimatedQueueTime: Instant,
    @Serializable(with = EpochSecondsInstantSerializer::class)
    val estimatedOnDeckTime: Instant,
    @Serializable(with = EpochSecondsInstantSerializer::class)
    val estimatedOnFieldTime: Instant,
    @Serializable(with = EpochSecondsInstantSerializer::class)
    val estimatedStartTime: Instant
)
