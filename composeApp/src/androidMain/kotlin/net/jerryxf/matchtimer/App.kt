package net.jerryxf.matchtimer

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.*
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp

@Composable
fun App() {
    val dark = isSystemInDarkTheme()
    var timer by remember { mutableStateOf(MatchTimer(null)) }
    val coroutineScope = rememberCoroutineScope()
    val liveActivity = remember { LiveActivity() }

    MaterialTheme {
        Surface(
            Modifier.fillMaxSize(),
            color = if (dark) Color(30, 31, 34) else Color.White,
            contentColor = if (dark) Color.White else Color.Black
        ) {
            Column(
                Modifier.fillMaxSize(),
                Arrangement.Top,
                Alignment.CenterHorizontally
            ) {
                Spacer(Modifier.height(50.dp))
                TopHeader(timer, coroutineScope, liveActivity)
                Phases()
            }
        }
    }
}
