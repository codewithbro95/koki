import SwiftUI

@main
struct KokiApp: App {
    @StateObject private var state = AppState()
    @Environment(\.openWindow) private var openWindow

    init() {
        NSApplication.shared.setActivationPolicy(.accessory)
        NSApplication.shared.applicationIconImage = EmojiIcon.make("🌮", size: 512)
    }

    var body: some Scene {
        MenuBarExtra("🌮") {
            Button("Read Selected Text (\(state.settings.hotKey.displayValue))") {
                state.readSelectedText()
            }

            Button("Stop Reading") {
                state.stopReading()
            }

            Divider()

            Button("Settings…") {
                NSApp.activate(ignoringOtherApps: true)
                openWindow(id: "settings")
            }
            .keyboardShortcut(",")

            Button("Check for Updates…") {
                state.checkForUpdates()
            }

            Button("About Koki") {
                state.showAbout()
            }

            Divider()

            Text(state.lastStatus)
                .font(.caption)
                .foregroundStyle(.secondary)

            Divider()

            Button("Quit Koki") {
                NSApp.terminate(nil)
            }
            .keyboardShortcut("q")
        }
        .menuBarExtraStyle(.menu)

        Window("Koki Settings", id: "settings") {
            SettingsView(state: state)
        }
        .windowResizability(.contentSize)
    }
}
