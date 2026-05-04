package net.jerryxf.technexus

import android.Manifest
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.app.NotificationCompat
import net.jerryxf.technexus.shared.settings.SettingsFactory

class MainActivity : ComponentActivity() {
    var notif: NotificationCompat.Builder? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)

        // Initialize the settings factory with the application context
        SettingsFactory.init(applicationContext)

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
