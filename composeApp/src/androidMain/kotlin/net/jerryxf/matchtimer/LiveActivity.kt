package net.jerryxf.matchtimer

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context.NOTIFICATION_SERVICE
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

class LiveActivity() {
    private lateinit var notif: NotificationCompat.Builder
    private val notifId = ++notifCount

    fun start() {
        notif = NotificationCompat.Builder(MainActivity.context, CHANNEL_ID)
            .setContentTitle("Match")
            .setSmallIcon(R.drawable.ic_launcher_foreground)
            .setOngoing(true)
            .setProgress(MatchState.MATCH_DURATION, 0, false)
        update()
    }

    private fun update() = with(NotificationManagerCompat.from(MainActivity.context)) {
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
                        NotificationManagerCompat.IMPORTANCE_MAX
                    )
                )
        }
    }
}
