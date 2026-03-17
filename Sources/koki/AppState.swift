import AppKit

@MainActor
final class AppState: ObservableObject {
    @Published var lastStatus = "Ready"

    let settings = AppSettings()

    var availableVoices: [SystemVoice] {
        systemVoices.sorted { lhs, rhs in
            lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
        }
    }

    var hasSystemVoices: Bool {
        availableVoices.isEmpty == false
    }

    private let hotKeyManager = HotKeyManager()
    private let reader = SelectedTextReader()
    private let speech = SpeechService()

    init() {
        settings.hotKeyDidChange = { [weak self] newHotKey in
            self?.registerHotKey(newHotKey)
        }

        ensureValidSelectedVoice()

        registerHotKey(settings.hotKey)
    }

    func readSelectedText() {
        ensureValidSelectedVoice()
        guard hasSystemVoices else {
            lastStatus = "No system voices installed. Open Settings to add one."
            return
        }
        lastStatus = "Capturing selected text..."

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            let selectedText = self.reader.captureSelectedText()

            Task { @MainActor in
                guard let selectedText else {
                    self.lastStatus = "No text selected (or Accessibility permission is required)."
                    return
                }

                self.speech.read(
                    selectedText,
                    voiceIdentifier: self.settings.selectedVoiceIdentifier,
                    rate: self.settings.speechRate
                )
                self.lastStatus = "Reading \(selectedText.count) characters"
            }
        }
    }

    func stopReading() {
        speech.stop()
        lastStatus = "Stopped"
    }

    func previewVoice() {
        ensureValidSelectedVoice()
        guard hasSystemVoices else {
            lastStatus = "No system voices installed. Open Settings to add one."
            return
        }
        speech.read(
            "Hello from Koki. I can read selected text anywhere on your Mac.",
            voiceIdentifier: settings.selectedVoiceIdentifier,
            rate: settings.speechRate
        )
        lastStatus = "Previewing system voice"
    }

    func checkForUpdates() {
        guard let url = URL(string: "https://github.com/codewithbro95/koki") else { return }
        NSWorkspace.shared.open(url)
    }

    func showAbout() {
        NSApp.activate(ignoringOtherApps: true)
        let icon = EmojiIcon.make("🌮", size: 256)
        let credits = NSAttributedString(
            string: "Open source. Built with love by fotiecodes.\nMIT License.",
            attributes: [
                .font: NSFont.systemFont(ofSize: 11),
                .foregroundColor: NSColor.secondaryLabelColor
            ]
        )
        NSApp.orderFrontStandardAboutPanel(options: [
            .applicationIcon: icon,
            .applicationVersion: AppVersion.marketing,
            .version: AppVersion.build,
            .credits: credits
        ])
    }

    private func registerHotKey(_ hotKey: HotKeyConfig) {
        hotKeyManager.register(hotKey) { [weak self] in
            Task { @MainActor in
                self?.readSelectedText()
            }
        }
        lastStatus = "Shortcut active: \(hotKey.displayValue)"
    }

    private var systemVoices: [SystemVoice] {
        NSSpeechSynthesizer.availableVoices.compactMap { voiceName in
            let attributes = NSSpeechSynthesizer.attributes(forVoice: voiceName)
            let name = attributes[.name] as? String ?? voiceName.rawValue
            let localeIdentifier = attributes[.localeIdentifier] as? String ?? ""
            let localeName = Locale.current.localizedString(forIdentifier: localeIdentifier) ?? localeIdentifier
            return SystemVoice(id: voiceName.rawValue, name: name, locale: localeName)
        }
    }

    private func ensureValidSelectedVoice() {
        guard let firstVoice = availableVoices.first else {
            settings.selectedVoiceIdentifier = ""
            return
        }

        let current = settings.selectedVoiceIdentifier
        let exists = availableVoices.contains { $0.id == current }

        if current.isEmpty || exists == false {
            settings.selectedVoiceIdentifier = firstVoice.id
        }
    }
}
