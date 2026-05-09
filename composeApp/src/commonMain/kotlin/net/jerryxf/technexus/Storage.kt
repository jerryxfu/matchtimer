package net.jerryxf.technexus

import com.russhwolf.settings.Settings
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.decodeFromByteArray
import kotlinx.serialization.encodeToByteArray

/**
 * Centralized app settings. Add new settings by following the pattern:
 *   1. Add KEY_ and DEFAULT_ constants
 *   2. Add get/set methods
 *   3. Update UI in SettingsView.kt (Android) and SettingsView.swift (iOS)
 */
class AppSettings(private val _settings: () -> Settings) {
    private val settings = lazy { _settings() }
    fun getEventId(): String =
        settings.value.getStringOrNull(KEY_EVENT_ID) ?: DEFAULT_EVENT_ID

    fun setEventId(eventId: String) {
        settings.value.putString(KEY_EVENT_ID, eventId)
    }

    fun getTeamNumber(): String =
        settings.value.getStringOrNull(KEY_TEAM_NUMBER) ?: DEFAULT_TEAM_NUMBER

    fun setTeamNumber(teamNumber: String) {
        settings.value.putString(KEY_TEAM_NUMBER, teamNumber)
    }

    companion object {
        private const val KEY_EVENT_ID = "event_id"
        private const val DEFAULT_EVENT_ID = "2026daly"

        private const val KEY_TEAM_NUMBER = "team_number"
        private const val DEFAULT_TEAM_NUMBER = "3990"
    }
}

object SettingsManager {
    val settings = AppSettings { createSettings() }
}

expect fun createSettings(): Settings

expect fun save(name: String, data: ByteArray)
expect fun save(name: String, data: String)

@OptIn(ExperimentalSerializationApi::class)
inline fun <reified T> save(name: String, data: T) = save(name, protoConfig.encodeToByteArray(data))

expect fun loadBytes(name: String): ByteArray?
expect fun loadString(name: String): String?

@OptIn(ExperimentalSerializationApi::class)
inline fun <reified T> load(name: String) = loadBytes(name)?.let { protoConfig.decodeFromByteArray<T>(it) }

expect fun exists(name: String): Boolean

expect fun delete(name: String): Boolean
