package net.jerryxf.technexus

import android.content.Context
import com.russhwolf.settings.Settings
import com.russhwolf.settings.SharedPreferencesSettings

private lateinit var context: Context

fun initSettings(ctx: Context) {
    context = ctx
}

actual fun createSettings(): Settings {
    val sharedPreferences = context.getSharedPreferences("app_settings", Context.MODE_PRIVATE)
    return SharedPreferencesSettings(sharedPreferences)
}
