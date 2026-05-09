package net.jerryxf.technexus

import android.Manifest
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.app.NotificationCompat

class MainActivity : ComponentActivity() {
    var notif: NotificationCompat.Builder? = null

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

        initSettings(applicationContext)
        initNotificationChannel(applicationContext)

        setContent {
            App()
        }
    }

    override fun onDestroy() {
        dispose()
        super.onDestroy()
    }
}
