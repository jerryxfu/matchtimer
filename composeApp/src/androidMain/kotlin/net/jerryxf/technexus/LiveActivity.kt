package net.jerryxf.technexus

import android.Manifest
import android.annotation.SuppressLint
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Context.NOTIFICATION_SERVICE
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

@SuppressLint("StaticFieldLeak")
private lateinit var notif: NotificationCompat.Builder
private const val CHANNEL_ID = "LiveActivity"
private val notifStyle = NotificationCompat.ProgressStyle()
    .addProgressSegment(NotificationCompat.ProgressStyle.Segment(20))
    .addProgressSegment(NotificationCompat.ProgressStyle.Segment(3))
    .addProgressSegment(NotificationCompat.ProgressStyle.Segment(10))
    .addProgressSegment(NotificationCompat.ProgressStyle.Segment(25))
    .addProgressSegment(NotificationCompat.ProgressStyle.Segment(25))
    .addProgressSegment(NotificationCompat.ProgressStyle.Segment(25))
    .addProgressSegment(NotificationCompat.ProgressStyle.Segment(25))
    .addProgressSegment(NotificationCompat.ProgressStyle.Segment(30))

fun MainActivity.startLiveActivity(context: Context) {
    notif = NotificationCompat.Builder(context, CHANNEL_ID)
        .setContentTitle("Match")
        .setSmallIcon(R.drawable.ic_launcher_foreground)
        .setRequestPromotedOngoing(true)
        .setOngoing(true)
        .setShowWhen(false)
        .setStyle(notifStyle.setProgress(0))

    update(context)
}

private fun MainActivity.update(context: Context) = with(NotificationManagerCompat.from(context)) {
    if (ActivityCompat.checkSelfPermission(
            context,
            Manifest.permission.POST_NOTIFICATIONS
        ) != PackageManager.PERMISSION_GRANTED
    ) ActivityCompat.requestPermissions(this@update, arrayOf(Manifest.permission.POST_NOTIFICATIONS), 0)
    notify(1, notif.build())
}

fun MainActivity.setActivityProgress(state: MatchState, context: Context) {
    notif.setStyle(notifStyle.setProgress((state.totalElapsed * 100) / MatchState.MATCH_DURATION))
    notif.setShortCriticalText(state.timeString())
    update(context)
}

fun initNotificationChannel(context: Context) {
    (context.getSystemService(NOTIFICATION_SERVICE) as NotificationManager)
        .createNotificationChannel(
            NotificationChannel(
                CHANNEL_ID,
                "Live activities",
                NotificationManager.IMPORTANCE_HIGH
            )
        )
}
