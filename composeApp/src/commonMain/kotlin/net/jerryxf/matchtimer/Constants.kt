package net.jerryxf.matchtimer

import androidx.compose.ui.graphics.Color
import io.ktor.client.HttpClient
import io.ktor.client.plugins.cache.HttpCache
import io.ktor.client.plugins.compression.ContentEncoding
import io.ktor.client.plugins.compression.ContentEncodingConfig
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.serialization.kotlinx.json.json
import net.jerryxf.matchtimer.shared.jsonConfig
import kotlin.time.Duration.Companion.seconds


val client = HttpClient {
    install(ContentNegotiation) {
        json(jsonConfig)
    }
    install(ContentEncoding) {
        deflate()
        gzip()
        identity()
        mode = ContentEncodingConfig.Mode.All
    }
    install(HttpCache)
}

val onField = "on field" to "Done" to Color.Gray
val onDeck = "on deck" to "On deck" to Color.Blue
val nowQueue = "now queuing" to "Now queuing" to Color.Yellow
val queueSoon = "queuing soon" to "Queuing soon" to Color.Magenta
val refreshInterval = 15.seconds
const val EVENT_ID = "2026nvlv" // TODO : setting
