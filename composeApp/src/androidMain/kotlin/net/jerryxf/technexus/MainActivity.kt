package net.jerryxf.technexus

import android.Manifest
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.result.contract.ActivityResultContracts

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

    override fun onDestroy() {
        client.close()
        super.onDestroy()
    }
}

fun MatchState.timeString(): String {
    val m = this.totalSecondsRemaining / 60
    val s = this.totalSecondsRemaining % 60
    return String.format("%d:%02d", m, s)
}
