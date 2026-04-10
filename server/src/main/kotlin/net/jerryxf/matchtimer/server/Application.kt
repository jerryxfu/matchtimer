package net.jerryxf.matchtimer.server

import io.ktor.client.HttpClient
import io.ktor.client.call.body
import io.ktor.client.request.get
import io.ktor.http.HttpStatusCode
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation as ClientContentNegotiation
import io.ktor.serialization.kotlinx.json.json
import io.ktor.server.application.Application
import io.ktor.server.application.ApplicationStopped
import io.ktor.server.application.install
import io.ktor.server.cio.CIO
import io.ktor.server.engine.embeddedServer
import io.ktor.server.plugins.contentnegotiation.ContentNegotiation as ServerContentNegotiation
import io.ktor.server.plugins.cors.routing.CORS
import io.ktor.server.response.respond
import io.ktor.server.routing.get
import io.ktor.server.routing.routing
import kotlinx.serialization.json.Json
import net.jerryxf.matchtimer.shared.Event
import net.jerryxf.matchtimer.shared.jsonConfig
import java.io.File

val server = embeddedServer(CIO, 6867, "0.0.0.0", module = Application::module)

val apiKey = File("apiKey").readText().trim()

fun main() {
    server.start(true)
}

fun Application.module() {
    install(CORS) {
        anyHost()
        anyMethod()
    }
    install(ServerContentNegotiation) {
        json(jsonConfig)
    }

    server.monitor.subscribe(ApplicationStopped) { client.close() }

    routing {
        get("/event/{event}") {
            val event = call.parameters["event"]
            if (event.isNullOrBlank()) {
                call.respond(HttpStatusCode.BadRequest, "Invalid event")
                return@get
            }
            val resp = client.get("https://frc.nexus/api/v1/event/$event") {
                headers.append("Nexus-Api-Key", apiKey)
            }
            call.respond(resp.body<Event>())
        }
    }
}

val client = HttpClient {
    install(ClientContentNegotiation) {
        json(jsonConfig)
    }
}
