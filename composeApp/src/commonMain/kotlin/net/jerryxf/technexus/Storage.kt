package net.jerryxf.technexus

import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.encodeToByteArray
import kotlinx.serialization.decodeFromByteArray

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
