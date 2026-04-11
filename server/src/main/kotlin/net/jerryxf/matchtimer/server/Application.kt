package net.jerryxf.matchtimer.server

import io.ktor.client.*
import io.ktor.client.call.*
import io.ktor.client.plugins.cache.*
import io.ktor.client.plugins.cache.storage.*
import io.ktor.client.plugins.compression.*
import io.ktor.client.request.*
import io.ktor.client.statement.*
import io.ktor.http.*
import io.ktor.http.CacheControl
import io.ktor.http.content.*
import io.ktor.serialization.kotlinx.json.*
import io.ktor.server.application.*
import io.ktor.server.cio.*
import io.ktor.server.engine.*
import io.ktor.server.plugins.cachingheaders.*
import io.ktor.server.plugins.compression.*
import io.ktor.server.plugins.compression.zstd.*
import io.ktor.server.plugins.cors.routing.*
import io.ktor.server.plugins.forwardedheaders.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import net.jerryxf.matchtimer.shared.MatchId
import net.jerryxf.matchtimer.shared.MatchScore
import net.jerryxf.matchtimer.shared.jsonConfig
import java.io.File
import java.nio.file.Files
import java.nio.file.Paths
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation as ClientContentNegotiation
import io.ktor.server.plugins.contentnegotiation.ContentNegotiation as ServerContentNegotiation

val server = embeddedServer(CIO, 6867, "0.0.0.0", module = Application::module)

val config = File("apiKey").readLines().map { it.trim() }

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
                headers.append("Nexus-Api-Key", config[0])
            }
            if (resp.status != HttpStatusCode.OK) {
                call.respond(HttpStatusCode.FailedDependency)
                println(resp.status.toString() + " : " + resp.bodyAsText())
                return@get
            }
            call.respondText(resp.bodyAsText(), ContentType.Application.Json, HttpStatusCode.OK)
        }

        get("/event/{event}/match/{matchId}") {
            call.caching = CachingOptions(CacheControl.MaxAge(3600))
            val event = call.parameters["event"]
            if (event.isNullOrBlank()) {
                call.respond(HttpStatusCode.BadRequest, "Invalid event")
                return@get
            }
            val matchId = try {
                call.parameters["matchId"]?.let { MatchId.fromShort(it) }
            } catch (e: Exception) {
                e.printStackTrace()
                null
            }
            if (matchId == null) {
                call.respond(HttpStatusCode.BadRequest, "Invalid match id")
                return@get
            }

            val resp = client.get("https://www.thebluealliance.com/api/v3/match/${matchId.getTBAKey(event)}") {
                headers.append("X-TBA-Auth-Key", config[1])
            }
            if (resp.status != HttpStatusCode.OK) {
                call.respond(HttpStatusCode.FailedDependency)
                println(resp.status.toString() + " : " + resp.bodyAsText())
                return@get
            }
            val score = resp.body<TBAMatch>()
            call.respond(MatchScore(score.alliances.blue.score, score.alliances.red.score))
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
