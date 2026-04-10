package net.jerryxf.matchtimer.backend

import io.ktor.client.call.body
import io.ktor.client.request.get
import net.jerryxf.matchtimer.client

suspend fun getEventData(eventKey: String): Event? {
    return try {
        client.get("https://frc.nexus/api/v1/event/$eventKey") {
            headers.append("Nexus-Api-Key", "")// TODO : figure out
        }.body<Event>()
    } catch(e: Exception) {
        e.printStackTrace()
        null
    }
}
