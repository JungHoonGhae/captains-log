import Foundation
import AppKit

class NotificationManager {
    static let shared = NotificationManager()

    private var previousRank: PirateRank?

    func requestPermission() {}

    func checkRankChange(newRank: PirateRank, waterLevel: Double) {
        defer { previousRank = newRank }

        guard let oldRank = previousRank else { return }
        guard oldRank != newRank else { return }

        if newRank > oldRank {
            let msg = L10n.notifSinking(newRank)
            send(title: msg.title, body: msg.body)
        }

        if newRank < oldRank {
            let msg = L10n.notifRising(newRank, from: oldRank)
            send(title: msg.title, body: msg.body)
        }
    }

    private func send(title: String, body: String) {
        guard !title.isEmpty else { return }

        let escaped = { (s: String) -> String in
            s.replacingOccurrences(of: "\\", with: "\\\\")
             .replacingOccurrences(of: "\"", with: "\\\"")
        }

        let source = "display notification \"\(escaped(body))\" with title \"\(escaped(title))\""
        if let script = NSAppleScript(source: source) {
            var error: NSDictionary?
            script.executeAndReturnError(&error)
        }
    }
}

extension PirateRank: Comparable {
    private var order: Int {
        switch self {
        case .captain:   return 0
        case .firstMate: return 1
        case .deckhand:  return 2
        case .castaway:  return 3
        case .davyJones: return 4
        }
    }

    static func < (lhs: PirateRank, rhs: PirateRank) -> Bool {
        lhs.order < rhs.order
    }
}
