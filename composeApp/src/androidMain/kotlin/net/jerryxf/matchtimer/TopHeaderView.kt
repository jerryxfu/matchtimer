package net.jerryxf.matchtimer

import androidx.compose.foundation.layout.*
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.CoroutineScope
import androidx.compose.runtime.collectAsState

@Composable
fun TopHeader(timer: MatchTimer, coroutineScope: CoroutineScope, activity: LiveActivity) {
    Text(timer.matchState.collectAsState().value.timeString(), fontSize = 50.sp)
    Row(Modifier.fillMaxWidth(), Arrangement.SpaceEvenly) {
        Spacer(Modifier.width(10.dp))
        Button({
            timer.start(coroutineScope) { activity.setProgress(it) }
            activity.start()
        }, Modifier.weight(.5f)) { Text("Start") }
        Spacer(Modifier.width(10.dp))
        Button({ timer.stop() }, Modifier.weight(.5f)) { Text("Stop") }
        Spacer(Modifier.width(10.dp))
    }
}

fun MatchState.timeString(): String {
    val m = this.totalSecondsRemaining / 60
    val s = this.totalSecondsRemaining % 60
    return String.format("%d:%02d", m, s)
}
