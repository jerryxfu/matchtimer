package net.jerryxf.matchtimer

expect fun save(name: String, data: ByteArray)
expect fun save(name: String, data: String)

expect fun loadBytes(name: String): ByteArray?
expect fun loadString(name: String): String?

expect fun exists(name: String): Boolean

expect fun delete(name: String): Boolean
