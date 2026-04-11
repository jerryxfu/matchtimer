package net.jerryxf.matchtimer

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import java.io.File

class MainActivity : ComponentActivity() {
    companion object {
        lateinit var filesDir: File
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)
        Companion.filesDir = filesDir

        setContent {
        }
    }

    override fun onDestroy() {
        client.close()
        super.onDestroy()
    }
}
