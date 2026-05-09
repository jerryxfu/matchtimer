package net.jerryxf.technexus.server

import io.ktor.client.request.get
import io.ktor.client.statement.bodyAsText
import io.ktor.http.CacheControl
import io.ktor.http.ContentType
import io.ktor.http.HttpStatusCode
import io.ktor.http.content.CachingOptions
import io.ktor.server.application.Application
import io.ktor.server.plugins.cachingheaders.caching
import io.ktor.server.response.respond
import io.ktor.server.response.respondText
import io.ktor.server.routing.get
import io.ktor.server.routing.routing

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
