import AppKit

enum EmojiIcon {
    static func make(_ emoji: String, size: CGFloat) -> NSImage {
        let image = NSImage(size: NSSize(width: size, height: size))
        image.lockFocus()

        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: size * 0.8),
            .paragraphStyle: centeredParagraphStyle
        ]

        let rect = NSRect(x: 0, y: (size * 0.1), width: size, height: size)
        emoji.draw(in: rect, withAttributes: attributes)
        image.unlockFocus()
        return image
    }

    private static var centeredParagraphStyle: NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        return style
    }
}
