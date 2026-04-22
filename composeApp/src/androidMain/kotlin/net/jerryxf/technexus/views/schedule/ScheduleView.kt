package net.jerryxf.technexus.views.schedule

import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import net.jerryxf.technexus.EVENT_ID
import net.jerryxf.technexus.getEventData
import net.jerryxf.technexus.shared.Event

@Composable
fun ScheduleView() {
    var event: Event? by remember { mutableStateOf(null) }
    LaunchedEffect(EVENT_ID) {
        event = getEventData(EVENT_ID)
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
