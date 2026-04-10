package net.jerryxf.matchtimer

import io.ktor.client.HttpClient
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.serialization.kotlinx.json.json
import kotlinx.serialization.json.Json
import kotlinx.serialization.modules.SerializersModule
import net.jerryxf.matchtimer.backend.EpochSecondsInstantSerializer
import kotlin.time.Instant

const val NEXUS_HEADER = "Nexus-Api-Key"

val json = Json {
    serializersModule = SerializersModule {
        contextual(Instant::class, EpochSecondsInstantSerializer)
    }
    ignoreUnknownKeys = true
}

val client = HttpClient {
    install(ContentNegotiation) {
        json(json)
    }
}
