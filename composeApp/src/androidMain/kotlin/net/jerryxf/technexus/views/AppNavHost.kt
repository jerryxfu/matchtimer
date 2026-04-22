package net.jerryxf.technexus.views

import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import net.jerryxf.technexus.Destination
import net.jerryxf.technexus.views.schedule.ScheduleView

@Composable
fun AppNavHost(nav: NavHostController, startDestination: Destination, modifier: Modifier = Modifier) {
    NavHost(nav, startDestination.route, modifier) {
        Destination.entries.forEach { destination ->
            composable(destination.route) {
                when (destination) {
                    Destination.SCHEDULE -> ScheduleView()
                    else -> Text("Coming soon")
                }
            }
        }
    }
}
