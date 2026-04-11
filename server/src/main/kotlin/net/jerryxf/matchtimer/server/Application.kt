package net.jerryxf.matchtimer.server

import io.ktor.client.HttpClient
import io.ktor.client.plugins.cache.HttpCache
import io.ktor.client.plugins.cache.storage.FileStorage
import io.ktor.client.plugins.compression.ContentEncoding
import io.ktor.client.request.get
import io.ktor.client.statement.bodyAsText
import io.ktor.http.CacheControl
import io.ktor.http.ContentType
import io.ktor.http.HttpStatusCode
import io.ktor.http.content.CachingOptions
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation as ClientContentNegotiation
import io.ktor.serialization.kotlinx.json.json
import io.ktor.server.application.Application
import io.ktor.server.application.ApplicationStopped
import io.ktor.server.application.install
import io.ktor.server.cio.CIO
import io.ktor.server.engine.embeddedServer
import io.ktor.server.plugins.cachingheaders.CachingHeaders
import io.ktor.server.plugins.cachingheaders.caching
import io.ktor.server.plugins.compression.Compression
import io.ktor.server.plugins.compression.deflate
import io.ktor.server.plugins.compression.gzip
import io.ktor.server.plugins.compression.identity
import io.ktor.server.plugins.compression.zstd.zstd
import io.ktor.server.plugins.contentnegotiation.ContentNegotiation as ServerContentNegotiation
import io.ktor.server.plugins.cors.routing.CORS
import io.ktor.server.plugins.forwardedheaders.XForwardedHeaders
import io.ktor.server.response.respond
import io.ktor.server.response.respondText
import io.ktor.server.routing.get
import io.ktor.server.routing.routing
import net.jerryxf.matchtimer.shared.jsonConfig
import java.io.File
import java.nio.file.Files
import java.nio.file.Paths

val server = embeddedServer(CIO, 6867, "0.0.0.0", module = Application::module)

val apiKey = File("apiKey").readText().trim()

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

    routing {
        get("/event/{event}") {
            call.caching = CachingOptions(CacheControl.MaxAge(15))
            val event = call.parameters["event"]
            if (event.isNullOrBlank()) {
                call.respond(HttpStatusCode.BadRequest, "Invalid event")
                return@get
            }
            val resp = client.get("https://frc.nexus/api/v1/event/$event") {
                headers.append("Nexus-Api-Key", apiKey)
            }
            if (resp.status != HttpStatusCode.OK) {
                call.respond(HttpStatusCode.FailedDependency)
                return@get
            }
            call.respondText(resp.bodyAsText(), ContentType.Application.Json, HttpStatusCode.OK)
        }
    }
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
