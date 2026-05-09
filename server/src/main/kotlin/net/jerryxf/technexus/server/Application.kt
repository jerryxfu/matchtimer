package net.jerryxf.technexus.server

import io.ktor.client.*
import io.ktor.client.plugins.cache.*
import io.ktor.client.plugins.cache.storage.*
import io.ktor.client.plugins.compression.*
import io.ktor.serialization.kotlinx.json.*
import io.ktor.server.application.*
import io.ktor.server.cio.*
import io.ktor.server.engine.*
import io.ktor.server.plugins.cachingheaders.*
import io.ktor.server.plugins.compression.*
import io.ktor.server.plugins.compression.zstd.*
import io.ktor.server.plugins.cors.routing.*
import io.ktor.server.plugins.forwardedheaders.*
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
