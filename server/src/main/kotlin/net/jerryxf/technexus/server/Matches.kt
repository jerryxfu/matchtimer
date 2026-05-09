package net.jerryxf.technexus.server

import io.ktor.client.call.*
import io.ktor.client.request.*
import io.ktor.client.statement.*
import io.ktor.http.*
import io.ktor.http.content.*
import io.ktor.server.application.*
import io.ktor.server.plugins.cachingheaders.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import net.jerryxf.technexus.shared.MatchId
import net.jerryxf.technexus.shared.MatchScore

fun Application.matches() = routing {
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

        val resp =
            client.get("https://www.thebluealliance.com/api/v3/match/${matchId.getTBAKey(event)}") {
                headers.append("X-TBA-Auth-Key", tbaApiKey)
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
