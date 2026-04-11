package net.jerryxf.matchtimer

import io.ktor.client.call.*
import io.ktor.client.request.*
import net.jerryxf.matchtimer.shared.Event

suspend fun getEventData(eventKey: String): Event? {
    return try {
        client.get("https://nexus.raphdf201.net/event/$eventKey").body<Event>()
    } catch (e: Exception) {
        e.printStackTrace()
        null
    }
}
