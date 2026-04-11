package net.jerryxf.matchtimer.views

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ChevronLeft
import androidx.compose.material.icons.filled.ChevronRight
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import net.jerryxf.matchtimer.formatTime
import net.jerryxf.matchtimer.relativeTime
import net.jerryxf.matchtimer.roundCorners
import net.jerryxf.matchtimer.shared.MatchTimes

private data class TimingEntry(
    val label: String,
    val epoch: Long?
)

@Composable
fun TimingCarouselView(times: MatchTimes) {
    val entries = remember(times) {
        listOf(
            TimingEntry("Queue", times.estimatedQueueTime),
            TimingEntry("On Deck", times.estimatedOnDeckTime),
            TimingEntry("On Field", times.estimatedOnFieldTime),
            TimingEntry("Start", times.estimatedStartTime),
        )
    }

    val nextUpcomingIndex = remember(entries) {
        val now = System.currentTimeMillis().toDouble()
        entries.indexOfFirst { (it.epoch ?: 0L).toDouble() > now }
            .takeIf { it >= 0 } ?: (entries.size - 1)
    }

    val pagerState = rememberPagerState(
        initialPage = nextUpcomingIndex,
        pageCount = { entries.size }
    )

    Row(
        Modifier.background(Color.LightGray, roundCorners).padding(5.dp),
        Arrangement.spacedBy(8.dp),
        Alignment.CenterVertically
    ) {
        Row(horizontalArrangement = Arrangement.spacedBy(2.dp)) {
            Icon(
                Icons.Default.ChevronLeft,
                null,
                Modifier.size(12.dp),
                if (pagerState.currentPage > 0)
                    MaterialTheme.colorScheme.onSurfaceVariant
                else
                    MaterialTheme.colorScheme.onSurface.copy(0.3f)
            )
            Icon(
                Icons.Default.ChevronRight,
                null,
                Modifier.size(12.dp),
                if (pagerState.currentPage < entries.size - 1)
                    MaterialTheme.colorScheme.onSurfaceVariant
                else
                    MaterialTheme.colorScheme.onSurface.copy(0.3f),
            )
        }

        HorizontalPager(pagerState, Modifier.weight(1f).height(24.dp)) { index ->
            val entry = entries[index]
            Row(
                Modifier,
                Arrangement.spacedBy(4.dp),
                Alignment.CenterVertically
            ) {
                Text(
                    "${entry.label}:",
                    fontSize = 14.sp
                )
                Text(
                    entry.epoch?.let {
                        relativeTime(it)
                    } ?: "N/A",
                    fontSize = 14.sp
                )
                Text(
                    "(" + (entry.epoch?.let {
                        formatTime(it)
                    } ?: "N/A") + ")",
                    fontSize = 14.sp
                )
                Spacer(Modifier.weight(1f))
            }
        }

        Column(
            verticalArrangement = Arrangement.spacedBy(3.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            entries.forEachIndexed { i, _ ->
                Box(
                    Modifier
                        .size(4.dp)
                        .background(
                            if (pagerState.currentPage == i)
                                MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)
                            else
                                MaterialTheme.colorScheme.onSurface.copy(alpha = 0.25f),
                            CircleShape
                        )
                )
            }
        }
    }
}
