package net.jerryxf.technexus

import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.ui.unit.dp

val roundCorners = RoundedCornerShape(5.dp)

fun MatchState.timeString(): String {
    val m = this.totalSecondsRemaining / 60
    val s = this.totalSecondsRemaining % 60
    return String.format("%d:%02d", m, s)
}

fun dispose() {
    client.close()
}
