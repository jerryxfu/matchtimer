package net.jerryxf.technexus

import kotlinx.cinterop.*
import platform.Foundation.*
import platform.posix.memcpy

actual fun save(name: String, data: ByteArray) {
    val url = fileURL(name) ?: return
    val nsData = data.toNSData()
    nsData.writeToURL(url, atomically = true)
}

@OptIn(BetaInteropApi::class)
actual fun save(name: String, data: String) {
    val url = fileURL(name) ?: return
    val nsData = NSString.create(string = data)
        .dataUsingEncoding(NSUTF8StringEncoding) ?: return
    nsData.writeToURL(url, atomically = true)
}

actual fun loadBytes(name: String): ByteArray? {
    val url = fileURL(name) ?: return null
    return NSData.dataWithContentsOfURL(url)?.toByteArray()
}

@OptIn(ExperimentalForeignApi::class)
actual fun loadString(name: String): String? {
    val url = fileURL(name) ?: return null
    return NSString.stringWithContentsOfURL(url, NSUTF8StringEncoding, null)
}

actual fun exists(name: String): Boolean {
    val path = fileURL(name)?.path ?: return false
    return NSFileManager.defaultManager.fileExistsAtPath(path)
}

@OptIn(ExperimentalForeignApi::class)
actual fun delete(name: String): Boolean {
    val url = fileURL(name) ?: return false
    return memScoped {
        val error = alloc<ObjCObjectVar<NSError?>>()
        NSFileManager.defaultManager.removeItemAtURL(url, error.ptr)
    }
}

// helpers
private fun getAppSupportDir(): NSURL? =
    NSFileManager.defaultManager
        .URLsForDirectory(NSApplicationSupportDirectory, NSUserDomainMask)
        .lastOrNull() as? NSURL

private fun fileURL(name: String): NSURL? =
    getAppSupportDir()?.URLByAppendingPathComponent(name)

@OptIn(BetaInteropApi::class, ExperimentalForeignApi::class)
private fun ByteArray.toNSData(): NSData =
    this.usePinned { pinned ->
        NSData.create(bytes = pinned.addressOf(0), length = this.size.toULong())
    }

@OptIn(ExperimentalForeignApi::class)
private fun NSData.toByteArray(): ByteArray =
    ByteArray(this.length.toInt()).also { array ->
        array.usePinned { pinned ->
            memcpy(pinned.addressOf(0), this.bytes, this.length)
        }
    }
