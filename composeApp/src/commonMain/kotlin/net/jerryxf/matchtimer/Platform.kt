package net.jerryxf.matchtimer

interface Platform {
    val name: String
}

expect fun getPlatform(): Platform