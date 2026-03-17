# koki

`koki` is a native macOS menu bar app that reads selected text aloud from anywhere in macOS.

## Features

- Menu bar app (no dock icon)
- Global hotkey for reading currently selected text
- Settings window with:
  - configurable 2-key shortcut recorder (1 modifier + 1 key)
  - voice selection
  - speech rate
- About section and menu item
- Check-for-updates menu item

## Run

```bash
swift build
swift run
```

## First Launch Notes

`koki` needs macOS Accessibility permission so it can trigger copy (`⌘C`) on selected text in other apps.

- Open Settings in `koki`
- Click `Request Accessibility Permission`
- Enable `koki` in System Settings -> Privacy & Security -> Accessibility

For voices, `koki` uses the system voices listed in macOS. If none appear, install one in:

- System Settings -> Accessibility -> Spoken Content -> System Voice

## Update URL

By default, `Check for Updates` opens:

`https://github.com/your-org/koki/releases`

Change it in:

- `Sources/koki/AppState.swift`

## Key Files

- `Package.swift`
- `Sources/koki/KokiApp.swift`
- `Sources/koki/AppState.swift`
- `Sources/koki/HotKeyManager.swift`
- `Sources/koki/SelectedTextReader.swift`
- `Sources/koki/SpeechService.swift`
- `Sources/koki/SettingsView.swift`
- `Sources/koki/AppSettings.swift`
- `Sources/koki/Models.swift`
