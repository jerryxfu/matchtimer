package net.jerryxf.matchtimer

import androidx.compose.foundation.gestures.Orientation
import androidx.compose.foundation.gestures.scrollable
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.rememberScrollState
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier

@Composable
fun Phases() {
    Column(Modifier.scrollable(rememberScrollState(), Orientation.Vertical)) {
        Text("Auto")
        Text("Pause")
        Text("Transition")
        Text("Shift 1")
        Text("Shift 2")
        Text("Shift 3")
        Text("Shift 4")
        Text("Endgame")
        Text("Match over")
    }
}
