package net.jerryxf.technexus.shared.settings

import android.content.Context
import com.russhwolf.settings.Settings
import com.russhwolf.settings.SharedPreferencesSettings

actual object SettingsFactory {
    private var context: Context? = null

    fun init(context: Context) {
        this.context = context
    }

    actual fun createSettings(): Settings {
        val ctx = context
            ?: throw IllegalStateException("SettingsFactory must be initialized with a Context first")
        val sharedPreferences = ctx.getSharedPreferences("app_settings", Context.MODE_PRIVATE)
        return SharedPreferencesSettings(sharedPreferences)
    }
}