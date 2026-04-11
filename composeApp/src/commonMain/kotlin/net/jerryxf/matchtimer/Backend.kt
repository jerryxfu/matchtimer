package net.jerryxf.matchtimer

import io.ktor.client.call.body
import io.ktor.client.request.get
import net.jerryxf.matchtimer.shared.Event
import net.jerryxf.matchtimer.shared.MatchId
import net.jerryxf.matchtimer.shared.MatchScore

suspend fun getEventData(eventKey: String): Event? {
    return try {
        client.get("https://nexus.raphdf201.net/event/$eventKey").body<Event>()
    } catch(e: Exception) {
        e.printStackTrace()
        null
    }
}

suspend fun getMatchScore(event: String, match: MatchId): MatchScore? {
    val matchId = match.type.short + match.number

    return try {
        client.get("https://nexus.raphdf201.net/event/$event/match/$matchId").body()
    } catch (e: Exception) {
        e.printStackTrace()
        null
    }
}
