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

For voices, `koki` uses the system voices listed in macOS.
