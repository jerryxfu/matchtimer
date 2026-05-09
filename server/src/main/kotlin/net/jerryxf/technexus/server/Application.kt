package net.jerryxf.technexus.server

import io.ktor.client.HttpClient
import io.ktor.client.plugins.cache.HttpCache
import io.ktor.client.plugins.cache.storage.FileStorage
import io.ktor.client.plugins.compression.ContentEncoding
import io.ktor.serialization.kotlinx.json.json
import io.ktor.server.application.Application
import io.ktor.server.application.ApplicationStopped
import io.ktor.server.application.install
import io.ktor.server.cio.CIO
import io.ktor.server.engine.embeddedServer
import io.ktor.server.plugins.cachingheaders.CachingHeaders
import io.ktor.server.plugins.compression.Compression
import io.ktor.server.plugins.compression.deflate
import io.ktor.server.plugins.compression.gzip
import io.ktor.server.plugins.compression.identity
import io.ktor.server.plugins.compression.zstd.zstd
import io.ktor.server.plugins.cors.routing.CORS
import io.ktor.server.plugins.forwardedheaders.XForwardedHeaders
import net.jerryxf.technexus.shared.jsonConfig
import org.jetbrains.exposed.v1.jdbc.Database
import java.io.File
import java.nio.file.Files
import java.nio.file.Paths
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation as ClientContentNegotiation
import io.ktor.server.plugins.contentnegotiation.ContentNegotiation as ServerContentNegotiation

val server = embeddedServer(CIO, 6867, "0.0.0.0", module = Application::module)

private val config = File("apiKey").readLines().map { it.trim() }
val nexusApiKey = config[0]
val tbaApiKey = config[1]
val dbUrl = config[2]
val dbUser = config[3]
val dbPassword = config[4]

fun main() {
    server.start(true)
}

fun Application.module() {
    install(CORS) {
        anyHost()
        maxAgeInSeconds = 3600
    }
    install(ServerContentNegotiation) {
        json(jsonConfig)
    }
    install(Compression) {
        gzip()
        deflate()
        identity()
        zstd()
    }
    install(CachingHeaders)
    install(XForwardedHeaders)

    server.monitor.subscribe(ApplicationStopped) { client.close() }

    Database.connect("jdbc:postgresql://$dbUrl", "org.postgresql.Driver", dbUser, dbPassword)

    batteries()
    events()
    matches()
}

val client = HttpClient {
    install(ClientContentNegotiation) {
        json(jsonConfig)
    }
    install(ContentEncoding) {
        deflate()
        gzip()
        identity()
    }
    install(HttpCache) {
        publicStorage(FileStorage(Files.createDirectories(Paths.get("ktorCache")).toFile()))
    }
}
