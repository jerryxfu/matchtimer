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
    private val notifStyle = NotificationCompat.ProgressStyle()
        .addProgressSegment(NotificationCompat.ProgressStyle.Segment(20))
        .addProgressSegment(NotificationCompat.ProgressStyle.Segment(3))
        .addProgressSegment(NotificationCompat.ProgressStyle.Segment(10))
        .addProgressSegment(NotificationCompat.ProgressStyle.Segment(25))
        .addProgressSegment(NotificationCompat.ProgressStyle.Segment(25))
        .addProgressSegment(NotificationCompat.ProgressStyle.Segment(25))
        .addProgressSegment(NotificationCompat.ProgressStyle.Segment(25))
        .addProgressSegment(NotificationCompat.ProgressStyle.Segment(30))
    private val notifId = ++notifCount

    fun start() {
        notif = NotificationCompat.Builder(MainActivity.context, CHANNEL_ID)
            .setContentTitle("Match")
            .setSmallIcon(R.drawable.ic_launcher_foreground)
            .setRequestPromotedOngoing(true)
            .setOngoing(true)
            .setShowWhen(false)
            .setStyle(notifStyle.setProgress(0))

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
        notif.setStyle(notifStyle.setProgress((state.totalElapsed * 100) / MatchState.MATCH_DURATION))
        notif.setShortCriticalText(state.timeString())
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
