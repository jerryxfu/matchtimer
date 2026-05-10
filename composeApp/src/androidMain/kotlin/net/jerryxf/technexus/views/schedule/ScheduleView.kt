package net.jerryxf.technexus.views.schedule

import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import net.jerryxf.technexus.SettingsManager
import net.jerryxf.technexus.getEventData
import net.jerryxf.technexus.shared.Event

@Composable
fun ScheduleView() {
    var event: Event? by remember { mutableStateOf(null) }
    val eventId = remember { SettingsManager.settings.getEventId() }
    LaunchedEffect(eventId) {
        event = getEventData(eventId)
    }

    if (event != null) {
        LazyColumn {
            items(event!!.matches) {
                MatchCard(it)
            }
        }
    } else {
        Text("Failed to fetch events")
    }
}
