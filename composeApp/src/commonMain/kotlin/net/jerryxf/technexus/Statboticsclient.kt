package net.jerryxf.technexus.statbotics

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONArray
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL

class StatboticsClient(
    private val baseUrl: String = BASE_URL,
) {
    companion object {
        const val BASE_URL = "https://api.statbotics.io/v3"
        private const val TIMEOUT_MS = 10_000
    }
    private suspend fun get(path: String): JSONObject = withContext(Dispatchers.IO) {
        val url = URL("$baseUrl$path")
        val conn = url.openConnection() as HttpURLConnection
        conn.connectTimeout = TIMEOUT_MS
        conn.readTimeout = TIMEOUT_MS
        conn.setRequestProperty("Accept", "application/json")
        try {
            when (val code = conn.responseCode) {
                200  -> JSONObject(conn.inputStream.bufferedReader().readText())
                404  -> throw StatboticsError.NotFound(path)
                429  -> throw StatboticsError.RateLimited
                else -> throw StatboticsError.NetworkError("HTTP $code for $path")
            }
        } catch (e: StatboticsError) {
            throw e
        } catch (e: Exception) {
            throw StatboticsError.NetworkError(e.message ?: "Unknown network error")
        } finally {
            conn.disconnect()
        }
    }

    private suspend fun getArray(path: String): JSONArray = withContext(Dispatchers.IO) {
        val url = URL("$baseUrl$path")
        val conn = url.openConnection() as HttpURLConnection
        conn.connectTimeout = TIMEOUT_MS
        conn.readTimeout = TIMEOUT_MS
        conn.setRequestProperty("Accept", "application/json")
        try {
            when (val code = conn.responseCode) {
                200  -> JSONArray(conn.inputStream.bufferedReader().readText())
                404  -> throw StatboticsError.NotFound(path)
                429  -> throw StatboticsError.RateLimited
                else -> throw StatboticsError.NetworkError("HTTP $code for $path")
            }
        } catch (e: StatboticsError) {
            throw e
        } catch (e: Exception) {
            throw StatboticsError.NetworkError(e.message ?: "Unknown network error")
        } finally {
            conn.disconnect()
        }
    }

    suspend fun getTeam(teamNumber: Int): StatboticsTeam {
        val j = get("/team/$teamNumber")
        return j.parseTeam()
    }

    suspend fun getTeams(
        country: String? = null,
        state: String? = null,
        district: String? = null,
        activeOnly: Boolean = true,
        metric: String = "norm_epa",
        limit: Int = 100,
        offset: Int = 0,
    ): List<StatboticsTeam> {
        val params = buildParams(
            "country" to country,
            "state" to state,
            "district" to district,
            "active" to if (activeOnly) "true" else null,
            "metric" to metric,
            "limit" to limit.toString(),
            "offset" to offset.toString(),
        )
        return getArray("/teams$params").parseList { it.parseTeam() }
    }


    suspend fun getTeamYear(teamNumber: Int, year: Int): StatboticsTeamYear {
        val j = get("/team_year/$teamNumber/$year")
        return j.parseTeamYear()
    }

    suspend fun getTeamYears(
        teamNumber: Int? = null,
        year: Int? = null,
        metric: String = "norm_epa",
        limit: Int = 100,
        offset: Int = 0,
    ): List<StatboticsTeamYear> {
        val params = buildParams(
            "team" to teamNumber?.toString(),
            "year" to year?.toString(),
            "metric" to metric,
            "limit" to limit.toString(),
            "offset" to offset.toString(),
        )
        return getArray("/team_years$params").parseList { it.parseTeamYear() }
    }

    suspend fun getEvent(eventKey: String): StatboticsEvent {
        val j = get("/event/$eventKey")
        return j.parseEvent()
    }

    suspend fun getEvents(
        year: Int? = null,
        country: String? = null,
        state: String? = null,
        district: String? = null,
        type: String? = null,
        week: Int? = null,
        limit: Int = 100,
        offset: Int = 0,
    ): List<StatboticsEvent> {
        val params = buildParams(
            "year" to year?.toString(),
            "country" to country,
            "state" to state,
            "district" to district,
            "type" to type,
            "week" to week?.toString(),
            "limit" to limit.toString(),
            "offset" to offset.toString(),
        )
        return getArray("/events$params").parseList { it.parseEvent() }
    }

    suspend fun getTeamEvent(teamNumber: Int, eventKey: String): StatboticsTeamEvent {
        val j = get("/team_event/$teamNumber/$eventKey")
        return j.parseTeamEvent()
    }

    suspend fun getTeamEvents(
        teamNumber: Int? = null,
        eventKey: String? = null,
        year: Int? = null,
        metric: String = "norm_epa",
        limit: Int = 100,
        offset: Int = 0,
    ): List<StatboticsTeamEvent> {
        val params = buildParams(
            "team" to teamNumber?.toString(),
            "event" to eventKey,
            "year" to year?.toString(),
            "metric" to metric,
            "limit" to limit.toString(),
            "offset" to offset.toString(),
        )
        return getArray("/team_events$params").parseList { it.parseTeamEvent() }
    }

    suspend fun getMatch(matchKey: String): StatboticsMatch {
        val j = get("/match/$matchKey")
        return j.parseMatch()
    }

    suspend fun getMatches(
        teamNumber: Int? = null,
        eventKey: String? = null,
        year: Int? = null,
        compLevel: String? = null,
        limit: Int = 100,
        offset: Int = 0,
    ): List<StatboticsMatch> {
        val params = buildParams(
            "team" to teamNumber?.toString(),
            "event" to eventKey,
            "year" to year?.toString(),
            "comp_level" to compLevel,
            "limit" to limit.toString(),
            "offset" to offset.toString(),
        )
        return getArray("/matches$params").parseList { it.parseMatch() }
    }

    suspend fun getYear(year: Int): StatboticsYear {
        val j = get("/year/$year")
        return j.parseYear()
    }

    suspend fun getYears(): List<StatboticsYear> =
        getArray("/years").parseList { it.parseYear() }

    private fun buildParams(vararg pairs: Pair<String, String?>): String {
        val query = pairs
            .filter { it.second != null }
            .joinToString("&") { "${it.first}=${it.second}" }
        return if (query.isEmpty()) "" else "?$query"
    }

    private fun <T> JSONArray.parseList(transform: (JSONObject) -> T): List<T> =
        (0 until length()).map { transform(getJSONObject(it)) }
}