import AppKit
import SwiftUI
@preconcurrency import ApplicationServices

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var selection: SettingsSection = .general
    @Published var selectedVoiceID: String
    @Published var hasAccessibilityPermission: Bool

    let appState: AppState
    let recorder: HotKeyRecorder

    var settings: AppSettings {
        appState.settings
    }

    var availableVoices: [SystemVoice] {
        appState.availableVoices
    }

    var hasSystemVoices: Bool {
        appState.hasSystemVoices
    }

    init(appState: AppState) {
        self.appState = appState
        self.selectedVoiceID = appState.settings.selectedVoiceIdentifier
        self.hasAccessibilityPermission = AXIsProcessTrusted()
        let recorder = HotKeyRecorder()
        self.recorder = recorder

        recorder.onHotKey = { [weak self] hotKey in
            self?.settings.hotKey = hotKey
        }
    }

    func refreshAccessibilityPermission() {
        hasAccessibilityPermission = AXIsProcessTrusted()
    }

    func updateSelectedVoice(_ id: String) {
        selectedVoiceID = id
        settings.selectedVoiceIdentifier = id
    }

    func syncSelectedVoice() {
        let current = settings.selectedVoiceIdentifier
        if current != selectedVoiceID {
            selectedVoiceID = current
        }
    }

    func requestAccessibilityPermission() {
        _ = AXIsProcessTrustedWithOptions([
            "AXTrustedCheckOptionPrompt": true
        ] as CFDictionary)
    }

    func previewVoice() {
        appState.previewVoice()
    }

    func stopReading() {
        appState.stopReading()
    }

    func checkForUpdates() {
        appState.checkForUpdates()
    }

    func showAbout() {
        appState.showAbout()
    }
}

@MainActor
final class HotKeyRecorder: ObservableObject {
    @Published private(set) var isRecording = false
    @Published private(set) var hint = "Hotkey must be exactly 2 keys: one modifier + one key."

    var onHotKey: ((HotKeyConfig) -> Void)?

    private var eventMonitor: Any?

    func start() {
        stop(resetHint: false)
        isRecording = true
        updateHint("Press exactly 2 keys: one modifier (⌘/⌥/⌃/⇧) + one key (including Space).")

        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { [weak self] event in
            guard let self else { return event }
            guard self.isRecording else { return event }
            return self.handle(event)
        }
    }

    func stop(resetHint: Bool = true) {
        isRecording = false
        if let eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
            self.eventMonitor = nil
        }
        if resetHint {
            updateHint("Hotkey must be exactly 2 keys: one modifier + one key.")
        }
    }

    private func handle(_ event: NSEvent) -> NSEvent? {
        if KeyOption.isModifierKeyCode(event.keyCode) {
            return nil
        }

        let modifiers = event.modifierFlags.intersection([.command, .option, .control, .shift])
        let activeModifierCount = [
            modifiers.contains(.command),
            modifiers.contains(.option),
            modifiers.contains(.control),
            modifiers.contains(.shift)
        ].filter { $0 }.count

        guard activeModifierCount == 1,
              let modifier = ModifierOption.from(eventFlags: modifiers) else {
            updateHint("Use exactly one modifier plus one key.")
            NSSound.beep()
            return nil
        }

        let hotKey = HotKeyConfig(
            keyCode: UInt32(event.keyCode),
            modifiers: modifier.flags
        )

        onHotKey?(hotKey)
        updateHint("Saved: \(hotKey.displayValue)")
        stop(resetHint: false)
        return nil
    }

    private func updateHint(_ text: String) {
        hint = text
    }
}
