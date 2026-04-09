package net.jerryxf.matchtimer.backend

import io.ktor.client.call.body
import io.ktor.client.request.get
import io.ktor.http.headers
import net.jerryxf.matchtimer.NEXUS_HEADER
import net.jerryxf.matchtimer.client

suspend fun getEventData(eventKey: String): Event? {
    return try {
        client.get("https://frc.nexus/api/v1/event/$eventKey") {
            headers {
                append(NEXUS_HEADER, "")// TODO : figure out
            }
        }.body<Event>()
    } catch (_: Exception) {
        null
    }
}
