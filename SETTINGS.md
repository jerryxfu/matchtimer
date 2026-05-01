# Settings System

Cross-platform settings using `multiplatform-settings` (russhwolf). Settings are stored in SharedPreferences (Android) and NSUserDefaults (iOS).

## Usage

```kotlin
// Kotlin (Android / Shared)
val eventId = SettingsManager.settings.getEventId()
SettingsManager.settings.setEventId("2025sfmid")
```

```swift
// Swift (iOS)
let eventId = SettingsManager.shared.settings.getEventId()
SettingsManager.shared.settings.setEventId(eventId: "2025sfmid")
```

## Adding a New Setting

**1. `AppSettings.kt`** — add key, default, getter, setter:

```kotlin
fun getMyThing(): String =
    settings.getStringOrNull(KEY_MY_THING) ?: DEFAULT_MY_THING

fun setMyThing(value: String) {
    settings.putString(KEY_MY_THING, value)
}

companion object {
    private const val KEY_MY_THING = "my_thing"
    private const val DEFAULT_MY_THING = "default"
}
```

**2. `SettingsView.kt`** (Android) — add a field and wire it to save.

**3. `SettingsView.swift`** (iOS) — add a field and wire it to save.

That's it. The platform factories, `SettingsManager`, and `Constants.kt` don't need changes.

## File Locations

```
shared/src/commonMain/.../settings/AppSettings.kt       ← all settings defined here
shared/src/commonMain/.../settings/SettingsManager.kt    ← singleton access
shared/src/androidMain/.../settings/SettingsFactory.android.kt
shared/src/iosMain/.../settings/SettingsFactory.ios.kt
shared/src/jvmMain/.../settings/SettingsFactory.jvm.kt
composeApp/src/androidMain/.../views/settings/SettingsView.kt
iosApp/iosApp/SettingsView.swift
```

## Android Init

`SettingsFactory.init(applicationContext)` must be called in `MainActivity.onCreate()` before any settings access.

## Current Settings

| Key | Default | Description |
|-----|---------|-------------|
| `event_id` | `"2026daly"` | Which event to fetch data for |
| `team_number` | `""` | FRC team number for highlighting |

## Supported Types

String, Int, Long, Float, Double, Boolean (and nullable variants) — all via `multiplatform-settings`.
