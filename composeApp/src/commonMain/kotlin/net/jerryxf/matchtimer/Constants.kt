package net.jerryxf.matchtimer

import io.ktor.client.HttpClient
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.serialization.kotlinx.json.json
import kotlinx.serialization.json.Json

val json = Json {
    ignoreUnknownKeys = true
}

val client = HttpClient {
    install(ContentNegotiation) {
        json(json)
    }
}
