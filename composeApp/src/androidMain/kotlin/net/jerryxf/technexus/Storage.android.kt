package net.jerryxf.technexus

import android.content.Context
import com.russhwolf.settings.Settings
import com.russhwolf.settings.SharedPreferencesSettings
import java.io.File

private lateinit var context: Context

fun initSettings(ctx: Context) {
    context = ctx
}

actual fun createSettings(): Settings {
    val sharedPreferences = context.getSharedPreferences("app_settings", Context.MODE_PRIVATE)
    return SharedPreferencesSettings(sharedPreferences)
}

private val dir = MainActivity.filesDir.absolutePath

actual fun save(name: String, data: ByteArray) = File(dir, name).writeBytes(data)
actual fun save(name: String, data: String) = File(dir, name).writeText(data)

actual fun loadBytes(name: String): ByteArray? = try {
    File(dir, name).readBytes()
} catch (e: Exception) {
    e.printStackTrace()
    null
}

actual fun loadString(name: String): String? = try {
    File(dir, name).readText()
} catch (e: Exception) {
    e.printStackTrace()
    null
}

actual fun exists(name: String) = File(dir, name).exists()

actual fun delete(name: String) = File(dir, name).delete()
