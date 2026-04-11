package net.jerryxf.matchtimer

import io.ktor.client.HttpClient
import io.ktor.client.plugins.cache.HttpCache
import io.ktor.client.plugins.compression.ContentEncoding
import io.ktor.client.plugins.compression.ContentEncodingConfig
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.serialization.kotlinx.json.json
import net.jerryxf.matchtimer.shared.jsonConfig

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
