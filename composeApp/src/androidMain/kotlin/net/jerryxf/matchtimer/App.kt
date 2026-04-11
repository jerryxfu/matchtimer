package net.jerryxf.matchtimer

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.tooling.preview.Preview

@Preview
@Composable
fun App() {
    val dark = isSystemInDarkTheme()

    MaterialTheme {
        Surface(
            Modifier.fillMaxSize(),
            color = if (dark) Color(30, 31, 34) else Color.White,
            contentColor = if (dark) Color.White else Color.Black
        ) {

        }
    }
}
