import AppKit

@MainActor
final class AppSettings: ObservableObject {
    @Published var hotKey: HotKeyConfig {
        didSet {
            let normalized = hotKey.normalizedToTwoKeys
            if hotKey != normalized {
                hotKey = normalized
                return
            }
            saveHotKey()
            hotKeyDidChange?(hotKey)
        }
    }

    @Published var selectedVoiceIdentifier: String {
        didSet { defaults.set(selectedVoiceIdentifier, forKey: Keys.voiceIdentifier) }
    }

    @Published var speechRate: Double {
        didSet { defaults.set(speechRate, forKey: Keys.speechRate) }
    }

    var hotKeyDidChange: ((HotKeyConfig) -> Void)?

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        let storedCode = defaults.object(forKey: Keys.hotKeyCode) as? UInt32
        let storedModifiers = defaults.object(forKey: Keys.hotKeyModifiers) as? UInt32

        if let code = storedCode, let modifiers = storedModifiers {
            hotKey = HotKeyConfig(
                keyCode: code,
                modifiers: NSEvent.ModifierFlags(rawValue: UInt(modifiers))
            ).normalizedToTwoKeys
        } else {
            hotKey = .default
        }

        selectedVoiceIdentifier = defaults.string(forKey: Keys.voiceIdentifier) ?? ""

        let persistedRate = defaults.object(forKey: Keys.speechRate) as? Double
        speechRate = AppSettings.normalizedRate(from: persistedRate)
    }

    private func saveHotKey() {
        defaults.set(hotKey.keyCode, forKey: Keys.hotKeyCode)
        defaults.set(hotKey.modifiers.rawValue, forKey: Keys.hotKeyModifiers)
    }

    private static func normalizedRate(from storedValue: Double?) -> Double {
        guard let storedValue else { return 180 }

        if storedValue <= 1.0 {
            let clamped = min(max(storedValue, 0.1), 0.8)
            let t = (clamped - 0.1) / 0.7
            return 180 + (t * 120)
        }

        return min(max(storedValue, 120), 320)
    }

    private enum Keys {
        static let hotKeyCode = "hotkey.code"
        static let hotKeyModifiers = "hotkey.modifiers"
        static let voiceIdentifier = "speech.voiceIdentifier"
        static let speechRate = "speech.rate"
    }
}
