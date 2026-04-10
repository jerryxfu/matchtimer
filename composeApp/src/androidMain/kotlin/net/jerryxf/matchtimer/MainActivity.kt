package net.jerryxf.matchtimer

import android.Manifest
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.gestures.Orientation
import androidx.compose.foundation.gestures.scrollable
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)

        val requestPermissionLauncher = registerForActivityResult(
            ActivityResultContracts.RequestPermission()
        ) { isGranted ->
            if (!isGranted)
                println("no notifs for you")
        }

        requestPermissionLauncher.launch(Manifest.permission.POST_NOTIFICATIONS)

        initNotificationChannel(applicationContext)

        setContent {
            App()
        }
    }

    @Preview
    @Composable
    private fun App() {
        val dark = isSystemInDarkTheme()
        var timer by remember { mutableStateOf(MatchTimer(null)) }
        val coroutineScope = rememberCoroutineScope()

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

                    Text(timer.matchState.collectAsState().value.timeString(), fontSize = 50.sp)
                    Row(Modifier.fillMaxWidth(), Arrangement.SpaceEvenly) {
                        Spacer(Modifier.width(10.dp))
                        Button({
                            timer.start(coroutineScope) { setActivityProgress(it, applicationContext) }
                            startLiveActivity(applicationContext)
                        }, Modifier.weight(.5f), colors = ButtonDefaults.buttonColors(containerColor = Color.Green)) {
                            Text("Start")
                        }
                        Spacer(Modifier.width(10.dp))
                        Button({ timer.stop() }, Modifier.weight(.5f),
                            colors = ButtonDefaults.buttonColors(containerColor = Color.Red)) {
                            Text("Stop")
                        }
                        Spacer(Modifier.width(10.dp))
                    }

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
            }
        }
    }
}

fun MatchState.timeString(): String {
    val m = this.totalSecondsRemaining / 60
    val s = this.totalSecondsRemaining % 60
    return String.format("%d:%02d", m, s)
}
