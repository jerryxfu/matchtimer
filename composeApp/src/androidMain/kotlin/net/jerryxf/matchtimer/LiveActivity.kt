package net.jerryxf.matchtimer

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context.NOTIFICATION_SERVICE
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

class LiveActivity {
    private lateinit var notif: NotificationCompat.Builder
    private val notifId = ++notifCount

    fun start() {
        notif = NotificationCompat.Builder(MainActivity.context, CHANNEL_ID)
            .setContentTitle("Match")
            .setSmallIcon(R.drawable.ic_launcher_foreground)
            .setRequestPromotedOngoing(true)
            .setOngoing(true)
            .setProgress(MatchState.MATCH_DURATION, 0, false)
        update()
    }

    private fun update() = with(NotificationManagerCompat.from(MainActivity.context)) {
        if (ActivityCompat.checkSelfPermission(
                MainActivity.context,
                Manifest.permission.POST_NOTIFICATIONS
            ) != PackageManager.PERMISSION_GRANTED
        ) ActivityCompat.requestPermissions(MainActivity.instance, arrayOf(Manifest.permission.POST_NOTIFICATIONS), 0)
        notify(notifId, notif.build())
    }

    fun setProgress(state: MatchState) {
        notif.setProgress(MatchState.MATCH_DURATION, state.totalElapsed, false)
        update()
    }

    companion object {
        private var notifCount = 0
        private const val CHANNEL_ID = "LiveActivity"

        init {
            (MainActivity.context.getSystemService(NOTIFICATION_SERVICE) as NotificationManager)
                .createNotificationChannel(
                    NotificationChannel(
                        CHANNEL_ID,
                        "Live activities",
                        NotificationManager.IMPORTANCE_HIGH
                    )
                )
        }
    }
}
