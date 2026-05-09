package net.jerryxf.technexus

import io.ktor.client.call.body
import io.ktor.client.request.delete
import io.ktor.client.request.get
import io.ktor.client.request.post
import io.ktor.client.request.put
import io.ktor.client.request.setBody
import io.ktor.http.HttpStatusCode
import net.jerryxf.technexus.shared.Battery
import net.jerryxf.technexus.shared.BatteryCycle
import net.jerryxf.technexus.shared.Event
import net.jerryxf.technexus.shared.MatchId
import net.jerryxf.technexus.shared.MatchScore

private const val apiUrl = "https://nexus.raphdf201.net"

suspend fun getEventData(eventKey: String): Event? {
    return try {
        client.get("$apiUrl/event/$eventKey").body<Event>()
    } catch (e: Exception) {
        e.printStackTrace()
        null
    }
}

suspend fun getMatchScore(event: String, match: MatchId): MatchScore? {
    val matchId = match.type.short + match.number

    return try {
        client.get("$apiUrl/event/$event/match/$matchId").body()
    } catch (e: Exception) {
        e.printStackTrace()
        null
    }
}

/**
 * Create a battery. Returns the battery's id.
 *
 * It doesn't care of the id you input initially
 */
suspend fun createBattery(bat: Battery): UInt? {
    return try {
        client.post("$apiUrl/batteries/new") {
            setBody(bat)
        }.body()
    } catch (e: Exception) {
        e.printStackTrace()
        null
    }
}

suspend fun getBatteries(): List<Battery> {
    return try {
        client.get("$apiUrl/batteries/all").body()
    } catch (e: Exception) {
        e.printStackTrace()
        emptyList()
    }
}

suspend fun getBattery(id: UInt): Battery? {
    return try {
        client.get("$apiUrl/batteries/$id").body()
    } catch (e: Exception) {
        e.printStackTrace()
        null
    }
}

suspend fun updateBattery(bat: Battery): Boolean {
    return try {
        client.put("$apiUrl/batteries/edit") {
            setBody(bat)
        }.status == HttpStatusCode.OK
    } catch (e: Exception) {
        e.printStackTrace()
        false
    }
}

suspend fun deleteBattery(bat: Battery): Boolean {
    return try {
        client.delete("$apiUrl/batteries/${bat.id}").status == HttpStatusCode.OK
    } catch (e: Exception) {
        e.printStackTrace()
        false
    }
}

/**
 * Create a cycle. Returns the created cycle.
 *
 * It ignores the ID you provide initially.
 */
suspend fun createCycle(cycle: BatteryCycle): UInt? {
    return try {
        client.post("$apiUrl/cycles/new") {
            setBody(cycle)
        }.body()
    } catch (e: Exception) {
        e.printStackTrace()
        null
    }
}

suspend fun getCycles(): List<BatteryCycle> {
    return try {
        client.get("$apiUrl/cycles/all").body()
    } catch (e: Exception) {
        e.printStackTrace()
        emptyList()
    }
}

suspend fun getCycle(id: UInt): BatteryCycle? {
    return try {
        client.get("$apiUrl/cycles/$id").body()
    } catch (e: Exception) {
        e.printStackTrace()
        null
    }
}

suspend fun updateCycle(cycle: BatteryCycle): BatteryCycle? {
    return try {
        client.put("$apiUrl/cycles/edit") {
            setBody(cycle)
        }.body()
    } catch (e: Exception) {
        e.printStackTrace()
        null
    }
}

suspend fun deleteCycle(cycle: BatteryCycle): Boolean {
    return try {
        client.delete("$apiUrl/cycles/${cycle.id}").status == HttpStatusCode.OK
    } catch (e: Exception) {
        e.printStackTrace()
        false
    }
}
