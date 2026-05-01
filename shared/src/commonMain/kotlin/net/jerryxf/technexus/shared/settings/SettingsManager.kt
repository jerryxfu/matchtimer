package net.jerryxf.technexus.shared.settings

import com.russhwolf.settings.Settings

expect object SettingsFactory {
    fun createSettings(): Settings
}

object SettingsManager {
    private val _settings = lazy { AppSettings(SettingsFactory.createSettings()) }

    val settings: AppSettings
        get() = _settings.value
}