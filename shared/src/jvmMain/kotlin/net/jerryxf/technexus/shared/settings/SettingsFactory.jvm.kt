package net.jerryxf.technexus.shared.settings

import com.russhwolf.settings.PreferencesSettings
import com.russhwolf.settings.Settings
import java.util.prefs.Preferences

actual object SettingsFactory {
    actual fun createSettings(): Settings {
        val preferences = Preferences.userRoot().node("technexus/app_settings")
        return PreferencesSettings(preferences)
    }
}