package net.jerryxf.matchtimer.views.schedule

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import net.jerryxf.matchtimer.*
import net.jerryxf.matchtimer.shared.Match

@Composable
fun MatchCard(match: Match) {
    Box(
        Modifier
            .fillMaxWidth()
            .padding(10.dp)
            .border(1.dp, Color.Black, roundCorners)
    ) {
        Column(Modifier
            .padding(10.dp)
            .fillMaxWidth()) {
            Row {
                Text(match.label)
                Spacer(Modifier.weight(1f))

                val statusInfo = getStatusBackgroundColor(match.status)
                if (statusInfo != null) {
                    Box(
                        Modifier
                            .background(statusInfo.second)
                            .border(1.dp, Color.Black, roundCorners),
                        Alignment.Center
                    ) {
                        Row {
                            statusInfo.third(Modifier.padding(4.dp, 2.dp, 1.dp, 2.dp))
                            Text(statusInfo.first, Modifier.padding(1.dp, 2.dp, 5.dp, 2.dp))
                        }
                    }
                } else {
                    Text("no status")
                }
            }
            Spacer(Modifier.height(10.dp))
            Row(Modifier.fillMaxWidth(), Arrangement.SpaceEvenly) {
                for (team in match.redTeams.filterNotNull()) {
                    Box(Modifier.border(1.dp, Color.Red, RoundedCornerShape(5.dp))) {
                        Text(team, Modifier.padding(4.dp, 2.dp, 4.dp, 2.dp))
                    }
                }
                for (team in match.blueTeams.filterNotNull()) {
                    Box(Modifier.border(1.dp, Color.Blue, RoundedCornerShape(5.dp))) {
                        Text(team, Modifier.padding(4.dp, 2.dp, 4.dp, 2.dp))
                    }
                }
            }
            Spacer(Modifier.height(15.dp))
            TimingCarouselView(match.times)
        }
    }
}

@Composable
private fun getStatusBackgroundColor(status: String): Triple<String, Color, @Composable (Modifier) -> Unit>? {
    return when (status.lowercase()) {
        onField.first.first -> Triple(onField.first.second, onField.second, ::FlagIcon)
        onDeck.first.first -> Triple(onDeck.first.second, onDeck.second, ::ClockIcon)
        nowQueue.first.first -> Triple(nowQueue.first.second, nowQueue.second, ::HumanIcon)
        queueSoon.first.first -> Triple(queueSoon.first.second, queueSoon.second, ::HourglassIcon)
        else -> null
    }
}
