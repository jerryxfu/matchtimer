package net.jerryxf.technexus

import com.russhwolf.settings.Settings

/**
 * Centralized app settings. Add new settings by following the pattern:
 *   1. Add KEY_ and DEFAULT_ constants
 *   2. Add get/set methods
 *   3. Update UI in SettingsView.kt (Android) and SettingsView.swift (iOS)
 */
class AppSettings(private val settings: Settings) {

    // ── Event ────────────────────────────────────────────────
    fun getEventId(): String =
        settings.getStringOrNull(KEY_EVENT_ID) ?: DEFAULT_EVENT_ID

    fun setEventId(eventId: String) {
        settings.putString(KEY_EVENT_ID, eventId)
    }

    // ── Team Number ──────────────────────────────────────────
    fun getTeamNumber(): String =
        settings.getStringOrNull(KEY_TEAM_NUMBER) ?: DEFAULT_TEAM_NUMBER

    fun setTeamNumber(teamNumber: String) {
        settings.putString(KEY_TEAM_NUMBER, teamNumber)
    }

    // ── Add new settings above this line ─────────────────────

    companion object {
        private const val KEY_EVENT_ID = "event_id"
        private const val DEFAULT_EVENT_ID = "2026daly"

        private const val KEY_TEAM_NUMBER = "team_number"
        private const val DEFAULT_TEAM_NUMBER = ""
    }
}

expect fun createSettings(): Settings

object SettingsManager {
    private val _settings = lazy { AppSettings(createSettings()) }

    val settings: AppSettings
        get() = _settings.value
}
