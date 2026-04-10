package net.jerryxf.matchtimer

import io.ktor.client.HttpClient
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.serialization.kotlinx.json.json
import net.jerryxf.matchtimer.shared.jsonConfig

val client = HttpClient {
    install(ContentNegotiation) {
        json(jsonConfig)
    }
}
