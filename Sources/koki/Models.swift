import AppKit
import Carbon

struct HotKeyConfig: Equatable {
    var keyCode: UInt32
    var modifiers: NSEvent.ModifierFlags

    static let `default` = HotKeyConfig(
        keyCode: KeyOption.r.keyCode,
        modifiers: ModifierOption.command.flags
    )

    var normalizedToTwoKeys: HotKeyConfig {
        let normalizedModifier = ModifierOption.from(modifiers: modifiers)?.flags ?? ModifierOption.command.flags
        return HotKeyConfig(keyCode: keyCode, modifiers: normalizedModifier)
    }

    var carbonModifiers: UInt32 {
        var flags: UInt32 = 0
        if modifiers.contains(.command) { flags |= UInt32(cmdKey) }
        if modifiers.contains(.option) { flags |= UInt32(optionKey) }
        if modifiers.contains(.control) { flags |= UInt32(controlKey) }
        if modifiers.contains(.shift) { flags |= UInt32(shiftKey) }
        return flags
    }

    var displayValue: String {
        var pieces: [String] = []
        if modifiers.contains(.command) { pieces.append("⌘") }
        if modifiers.contains(.option) { pieces.append("⌥") }
        if modifiers.contains(.control) { pieces.append("⌃") }
        if modifiers.contains(.shift) { pieces.append("⇧") }
        pieces.append(KeyOption.label(for: keyCode))
        return pieces.joined()
    }
}

enum KeyOption: String, CaseIterable, Identifiable {
    case a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z, space

    var id: String { rawValue }

    var keyCode: UInt32 {
        switch self {
        case .a: return 0
        case .b: return 11
        case .c: return 8
        case .d: return 2
        case .e: return 14
        case .f: return 3
        case .g: return 5
        case .h: return 4
        case .i: return 34
        case .j: return 38
        case .k: return 40
        case .l: return 37
        case .m: return 46
        case .n: return 45
        case .o: return 31
        case .p: return 35
        case .q: return 12
        case .r: return 15
        case .s: return 1
        case .t: return 17
        case .u: return 32
        case .v: return 9
        case .w: return 13
        case .x: return 7
        case .y: return 16
        case .z: return 6
        case .space: return 49
        }
    }

    var label: String {
        switch self {
        case .space: return "Space"
        default: return rawValue.uppercased()
        }
    }

    static func from(keyCode: UInt32) -> KeyOption? {
        allCases.first { $0.keyCode == keyCode }
    }

    static func label(for keyCode: UInt32) -> String {
        if let option = from(keyCode: keyCode) {
            return option.label
        }

        switch keyCode {
        case 36: return "Return"
        case 48: return "Tab"
        case 51: return "Delete"
        case 53: return "Esc"
        default: return "Key(\(keyCode))"
        }
    }

    static func isModifierKeyCode(_ keyCode: UInt16) -> Bool {
        // Left/right variants for Shift/Control/Option/Command, plus Caps Lock/Fn.
        let modifierCodes: Set<UInt16> = [54, 55, 56, 57, 58, 59, 60, 61, 62, 63]
        return modifierCodes.contains(keyCode)
    }
}

enum ModifierOption: String, CaseIterable, Identifiable {
    case command
    case option
    case control
    case shift

    var id: String { rawValue }

    var flags: NSEvent.ModifierFlags {
        switch self {
        case .command: return .command
        case .option: return .option
        case .control: return .control
        case .shift: return .shift
        }
    }

    var symbol: String {
        switch self {
        case .command: return "⌘"
        case .option: return "⌥"
        case .control: return "⌃"
        case .shift: return "⇧"
        }
    }

    var label: String {
        switch self {
        case .command: return "Command (⌘)"
        case .option: return "Option (⌥)"
        case .control: return "Control (⌃)"
        case .shift: return "Shift (⇧)"
        }
    }

    static func from(modifiers: NSEvent.ModifierFlags) -> ModifierOption? {
        if modifiers.contains(.command) { return .command }
        if modifiers.contains(.option) { return .option }
        if modifiers.contains(.control) { return .control }
        if modifiers.contains(.shift) { return .shift }
        return nil
    }

    static func from(eventFlags: NSEvent.ModifierFlags) -> ModifierOption? {
        let masked = eventFlags.intersection([.command, .option, .control, .shift])
        return from(modifiers: masked)
    }
}

struct SystemVoice: Identifiable, Equatable {
    let id: String
    let name: String
    let locale: String
}

enum SettingsSection: String, CaseIterable, Identifiable {
    case general
    case voice
    case about

    var id: String { rawValue }

    var title: String {
        switch self {
        case .general:
            return "General"
        case .voice:
            return "Voice"
        case .about:
            return "About"
        }
    }

    var systemImage: String {
        switch self {
        case .general:
            return "slider.horizontal.3"
        case .voice:
            return "waveform"
        case .about:
            return "info.circle"
        }
    }
}
