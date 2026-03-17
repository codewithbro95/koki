import AppKit
@preconcurrency import ApplicationServices

struct SelectedTextReader {
    func captureSelectedText() -> String? {
        guard requestAccessibilityIfNeeded() else {
            return nil
        }

        let pasteboard = NSPasteboard.general
        let snapshot = ClipboardSnapshot(from: pasteboard)

        performCopyShortcut()
        Thread.sleep(forTimeInterval: 0.12)

        let text = pasteboard.string(forType: .string)?.trimmingCharacters(in: .whitespacesAndNewlines)
        snapshot.restore(to: pasteboard)

        guard let text, text.isEmpty == false else { return nil }
        return text
    }

    private func requestAccessibilityIfNeeded() -> Bool {
        if AXIsProcessTrusted() {
            return true
        }

        let options = ["AXTrustedCheckOptionPrompt": true] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }

    private func performCopyShortcut() {
        guard let source = CGEventSource(stateID: .combinedSessionState) else { return }

        let commandDown = CGEvent(keyboardEventSource: source, virtualKey: 0x37, keyDown: true)
        let cDown = CGEvent(keyboardEventSource: source, virtualKey: 0x08, keyDown: true)
        cDown?.flags = .maskCommand
        let cUp = CGEvent(keyboardEventSource: source, virtualKey: 0x08, keyDown: false)
        cUp?.flags = .maskCommand
        let commandUp = CGEvent(keyboardEventSource: source, virtualKey: 0x37, keyDown: false)

        commandDown?.post(tap: .cghidEventTap)
        cDown?.post(tap: .cghidEventTap)
        cUp?.post(tap: .cghidEventTap)
        commandUp?.post(tap: .cghidEventTap)
    }
}

private struct ClipboardSnapshot {
    private struct Item {
        let valuesByType: [NSPasteboard.PasteboardType: Data]
    }

    private let items: [Item]

    init(from pasteboard: NSPasteboard) {
        let snapItems: [Item] = (pasteboard.pasteboardItems ?? []).map { pbItem in
            let map = Dictionary(uniqueKeysWithValues: pbItem.types.compactMap { type in
                pbItem.data(forType: type).map { (type, $0) }
            })
            return Item(valuesByType: map)
        }
        items = snapItems
    }

    func restore(to pasteboard: NSPasteboard) {
        pasteboard.clearContents()
        for item in items {
            let pbItem = NSPasteboardItem()
            for (type, data) in item.valuesByType {
                pbItem.setData(data, forType: type)
            }
            pasteboard.writeObjects([pbItem])
        }
    }
}
