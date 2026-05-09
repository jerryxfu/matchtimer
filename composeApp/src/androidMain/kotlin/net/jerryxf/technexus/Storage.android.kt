package net.jerryxf.technexus

import android.content.Context
import com.russhwolf.settings.Settings
import com.russhwolf.settings.SharedPreferencesSettings
import java.io.File

lateinit var context: Context

fun initSettings(ctx: Context) {
    context = ctx
}

actual fun createSettings(): Settings {
    val sharedPreferences = context.getSharedPreferences("app_settings", Context.MODE_PRIVATE)
    return SharedPreferencesSettings(sharedPreferences)
}

actual fun save(name: String, data: ByteArray) = File(context.filesDir, name).writeBytes(data)
actual fun save(name: String, data: String) = File(context.filesDir, name).writeText(data)

actual fun loadBytes(name: String): ByteArray? = try {
    File(context.filesDir, name).readBytes()
} catch (e: Exception) {
    e.printStackTrace()
    null
}

actual fun loadString(name: String): String? = try {
    File(context.filesDir, name).readText()
} catch (e: Exception) {
    e.printStackTrace()
    null
}

actual fun exists(name: String) = File(context.filesDir, name).exists()

actual fun delete(name: String) = File(context.filesDir, name).delete()
