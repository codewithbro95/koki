import Foundation

enum AppVersion {
    static let marketing = "0.0.1"
    static let build = "1"

    static var displayString: String {
        "Version \(marketing) (\(build))"
    }
}
