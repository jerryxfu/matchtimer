package net.jerryxf.matchtimer

import java.nio.file.Path

private val dir = MainActivity.filesDir.absolutePath

actual fun save(name: String, data: ByteArray) = Path.of(dir, name).toFile().writeBytes(data)
actual fun save(name: String, data: String) = Path.of(dir, name).toFile().writeText(data)

actual fun loadBytes(name: String): ByteArray? = try {
    Path.of(dir, name).toFile().readBytes()
} catch (e: Exception) {
    e.printStackTrace()
    null
}

actual fun loadString(name: String): String? = try {
    Path.of(dir, name).toFile().readText()
} catch (e: Exception) {
    e.printStackTrace()
    null
}

actual fun exists(name: String) = Path.of(dir, name).toFile().exists()

actual fun delete(name: String) = Path.of(dir, name).toFile().delete()
