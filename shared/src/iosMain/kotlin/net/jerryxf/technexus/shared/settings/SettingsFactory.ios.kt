package net.jerryxf.technexus.shared.settings

import com.russhwolf.settings.NSUserDefaultsSettings
import com.russhwolf.settings.Settings
import platform.Foundation.NSUserDefaults

actual object SettingsFactory {
    actual fun createSettings(): Settings {
        val userDefaults = NSUserDefaults.standardUserDefaults
        return NSUserDefaultsSettings(userDefaults)
    }
}