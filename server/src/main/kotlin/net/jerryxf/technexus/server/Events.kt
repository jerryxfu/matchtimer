package net.jerryxf.technexus.server

import io.ktor.client.request.*
import io.ktor.client.statement.*
import io.ktor.http.*
import io.ktor.http.content.*
import io.ktor.server.application.*
import io.ktor.server.plugins.cachingheaders.*
import io.ktor.server.response.*
import io.ktor.server.routing.*

fun Application.events() = routing {
    get("/event/{event}") {
        call.caching = CachingOptions(CacheControl.MaxAge(15))
        val event = call.parameters["event"]
        if (event.isNullOrBlank()) {
            call.respond(HttpStatusCode.BadRequest, "Invalid event")
            return@get
        }
        val resp = client.get("https://frc.nexus/api/v1/event/$event") {
            headers.append("Nexus-Api-Key", nexusApiKey)
        }
        if (resp.status != HttpStatusCode.OK) {
            call.respond(HttpStatusCode.FailedDependency)
            println(resp.status.toString() + " : " + resp.bodyAsText())
            return@get
        }
        call.respondText(resp.bodyAsText(), ContentType.Application.Json, HttpStatusCode.OK)
    }
}
