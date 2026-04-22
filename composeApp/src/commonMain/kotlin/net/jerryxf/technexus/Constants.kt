package net.jerryxf.technexus

import androidx.compose.ui.graphics.Color
import io.ktor.client.*
import io.ktor.client.plugins.cache.*
import io.ktor.client.plugins.compression.*
import io.ktor.client.plugins.contentnegotiation.*
import io.ktor.serialization.kotlinx.json.*
import net.jerryxf.technexus.shared.jsonConfig
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
