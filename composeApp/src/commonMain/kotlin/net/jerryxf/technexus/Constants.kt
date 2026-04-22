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

data class StatusConfig(val statusKey: String, val label: String, val color: Color)

val onField = StatusConfig("on field", "Done", Color.Gray)
val onDeck = StatusConfig("on deck", "On deck", Color.Blue)
val nowQueue = StatusConfig("now queuing", "Now queuing", Color.Yellow)
val queueSoon = StatusConfig("queuing soon", "Queuing soon", Color.Magenta)
val refreshInterval = 15.seconds
const val EVENT_ID = "2026nvlv" // TODO : setting
