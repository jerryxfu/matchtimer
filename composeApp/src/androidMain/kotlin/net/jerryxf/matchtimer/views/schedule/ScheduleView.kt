package net.jerryxf.matchtimer.views.schedule

import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.tooling.preview.Preview
import net.jerryxf.matchtimer.EVENT_ID
import net.jerryxf.matchtimer.getEventData
import net.jerryxf.matchtimer.shared.Event

@Preview
@Composable
fun ScheduleView() {
    var event: Event? by rememberSaveable { mutableStateOf(null) }
    LaunchedEffect(event) {
        val ev = getEventData(EVENT_ID)
        if (event == null) event = ev
        if (event != null && ev != null) event = ev
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
