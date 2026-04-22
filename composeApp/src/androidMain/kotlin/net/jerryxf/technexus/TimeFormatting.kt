package net.jerryxf.technexus

import java.text.DateFormat
import java.util.*
import kotlin.math.abs

/** Format an epoch (in milliseconds) as a short time string like "3:45 PM" */
fun formatTime(epochMs: Long): String {
    val date = Date(epochMs)
    val formatter = DateFormat.getTimeInstance(DateFormat.SHORT, Locale.getDefault())
    return formatter.format(date)
}

/** Format an epoch (in milliseconds) as a short date+time string */
fun formatDateTime(epochMs: Long): String {
    val date = Date(epochMs)
    val formatter = DateFormat.getDateTimeInstance(
        DateFormat.SHORT,
        DateFormat.SHORT,
        Locale.getDefault()
    )
    return formatter.format(date)
}

/** Relative time description like "in 5m", "in 1h 20m", "3m ago", "now" */
fun relativeTime(epochMs: Long): String {
    val diffMs = epochMs - System.currentTimeMillis()
    val diffSec = diffMs / 1000.0

    if (abs(diffSec) < 60) return "now"

    val minutes = (diffSec / 60).toInt()
    val hours = (diffSec / 3600).toInt()

    return if (diffSec > 0) {
        if (hours > 0) {
            val remainingMin = minutes - hours * 60
            if (remainingMin > 0) "in ${hours}h ${remainingMin}m" else "in ${hours}h"
        } else {
            "in ${minutes}m"
        }
    } else {
        val absHours = abs(hours)
        val absMinutes = abs(minutes)
        if (absHours > 0) {
            val remainingMin = absMinutes - absHours * 60
            if (remainingMin > 0) "${absHours}h ${remainingMin}m ago" else "${absHours}h ago"
        } else {
            "${absMinutes}m ago"
        }
    }
}
