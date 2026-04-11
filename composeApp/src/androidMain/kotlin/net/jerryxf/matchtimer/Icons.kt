package net.jerryxf.matchtimer

import androidx.compose.material3.Icon
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.rounded.DirectionsWalk
import androidx.compose.material.icons.rounded.Build
import androidx.compose.material.icons.rounded.CalendarMonth
import androidx.compose.material.icons.rounded.Flag
import androidx.compose.material.icons.rounded.HourglassBottom
import androidx.compose.material.icons.rounded.Schedule
import androidx.compose.material.icons.rounded.Settings
import androidx.compose.material.icons.rounded.Timer
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier

@Composable
fun CalendarIcon(modifier: Modifier = Modifier) = Icon(
    Icons.Rounded.CalendarMonth,
    "calendar_icon",
    modifier
)

@Composable
fun TimerIcon(modifier: Modifier = Modifier) = Icon(
    Icons.Rounded.Timer,
    "timer_icon",
    modifier
)

@Composable
fun HammerIcon(modifier: Modifier = Modifier) = Icon(
    Icons.Rounded.Build,
    "hammer_icon",
    modifier
)

@Composable
fun SettingsIcon(modifier: Modifier = Modifier) = Icon(
    Icons.Rounded.Settings,
    "settings_icon",
    modifier
)

@Composable
fun FlagIcon(modifier: Modifier = Modifier) = Icon(
    Icons.Rounded.Flag,
    "flag_icon",
    modifier
)

@Composable
fun ClockIcon(modifier: Modifier = Modifier) = Icon(
    Icons.Rounded.Schedule,
    "clock_icon",
    modifier
)

@Composable
fun HumanIcon(modifier: Modifier = Modifier) = Icon(
    Icons.AutoMirrored.Rounded.DirectionsWalk,
    "human_icon",
    modifier
)

@Composable
fun HourglassIcon(modifier: Modifier = Modifier) = Icon(
    Icons.Rounded.HourglassBottom,
    "hourglass_icon",
    modifier
)
