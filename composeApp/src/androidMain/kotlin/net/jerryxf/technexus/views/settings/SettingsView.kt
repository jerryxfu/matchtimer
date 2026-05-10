package net.jerryxf.technexus.views.settings

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Check
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.unit.dp
import kotlinx.coroutines.delay
import net.jerryxf.technexus.SettingsManager
import kotlin.time.Duration.Companion.milliseconds

@Composable
fun SettingsView(modifier: Modifier = Modifier) {
    val settings = SettingsManager.settings

    var eventId by remember { mutableStateOf(settings.getEventId()) }
    var teamNumber by remember { mutableStateOf(settings.getTeamNumber()) }
    var saved by remember { mutableStateOf(false) }

    LaunchedEffect(saved) {
        if (saved) {
            delay(2000.milliseconds)
            saved = false
        }
    }

    Column(
        modifier = modifier
            .fillMaxWidth()
            .verticalScroll(rememberScrollState())
            .padding(16.dp)
    ) {
        Text(
            text = "Settings",
            style = MaterialTheme.typography.headlineMedium,
            modifier = Modifier.padding(bottom = 24.dp)
        )

        // Event ID
        OutlinedTextField(
            value = eventId,
            onValueChange = { eventId = it },
            label = { Text("Event ID") },
            placeholder = { Text("e.g., 2026daly") },
            singleLine = true,
            textStyle = MaterialTheme.typography.bodyMedium.copy(fontFamily = FontFamily.Monospace),
            modifier = Modifier.fillMaxWidth()
        )
        Text(
            text = "Determines which competition data is fetched.",
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            modifier = Modifier.padding(top = 4.dp, bottom = 16.dp)
        )

        // Team Number
        OutlinedTextField(
            value = teamNumber,
            onValueChange = { teamNumber = it },
            label = { Text("Team Number") },
            placeholder = { Text("e.g., 1234") },
            singleLine = true,
            textStyle = MaterialTheme.typography.bodyMedium.copy(fontFamily = FontFamily.Monospace),
            modifier = Modifier.fillMaxWidth()
        )
        Text(
            text = "Your FRC team number for match highlighting.",
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            modifier = Modifier.padding(top = 4.dp, bottom = 24.dp)
        )

        // Save
        Button(
            onClick = {
                settings.setEventId(eventId)
                settings.setTeamNumber(teamNumber)
                saved = true
            },
            modifier = Modifier.fillMaxWidth()
        ) {
            if (saved) {
                Icon(Icons.Filled.Check, contentDescription = null, modifier = Modifier.padding(end = 8.dp))
            }
            Text(if (saved) "Saved" else "Save Settings")
        }

        if (saved) {
            Spacer(modifier = Modifier.height(12.dp))
            Text(
                text = "Settings saved successfully.",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.primary
            )
        }
    }
}
