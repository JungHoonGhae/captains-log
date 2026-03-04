import Foundation
import AppKit

class NotificationManager {
    static let shared = NotificationManager()

    private var previousRank: PirateRank?

    func requestPermission() {
        // NSAppleScript notifications don't need explicit permission
    }

    func checkRankChange(newRank: PirateRank, waterLevel: Double) {
        defer { previousRank = newRank }

        guard let oldRank = previousRank else { return }
        guard oldRank != newRank else { return }

        // Rank got worse (sinking)
        if newRank > oldRank {
            let (title, body) = sinkingMessage(for: newRank)
            send(title: title, body: body)
        }

        // Rank got better (rising)
        if newRank < oldRank {
            let (title, body) = risingMessage(for: newRank, from: oldRank)
            send(title: title, body: body)
        }
    }

    // MARK: - Sinking (getting worse)

    private func sinkingMessage(for rank: PirateRank) -> (String, String) {
        switch rank {
        case .captain:
            return ("", "")
        case .firstMate:
            return (
                "⚓ Demoted to First Mate!",
                "The sea be callin', mate... Get back to shippin'!"
            )
        case .deckhand:
            return (
                "🪝 Demoted to Deckhand!",
                "Ship's takin' water! Commit before ye walk the plank!"
            )
        case .castaway:
            return (
                "🏊 Ye be a Castaway now!",
                "ABANDON SHIP! Only a commit can save ye from Davy Jones!"
            )
        case .davyJones:
            return (
                "☠️ DAVY JONES CLAIMS YER SOUL!",
                "Ye sleep with the fishes now. COMMIT to resurrect!"
            )
        }
    }

    // MARK: - Rising (getting better)

    private func risingMessage(for rank: PirateRank, from oldRank: PirateRank) -> (String, String) {
        if oldRank == .davyJones {
            return (
                "🏴‍☠️ RESURRECTION!",
                "Ye cheated death! Back from Davy Jones' Locker! Keep shippin'!"
            )
        }

        switch rank {
        case .captain:
            return (
                "🏴‍☠️ Promoted to Captain!",
                "The sea is yers! Keep up the legendary shipping pace!"
            )
        case .firstMate:
            return (
                "⚓ Promoted to First Mate!",
                "One more push and ye'll be Captain again!"
            )
        case .deckhand:
            return (
                "🪝 Promoted to Deckhand!",
                "Water's recedin'. Keep committin'!"
            )
        case .castaway:
            return (
                "🏊 Still Castaway, but improving!",
                "Ye found driftwood! Keep committin' to get back aboard!"
            )
        case .davyJones:
            return ("", "")
        }
    }

    // MARK: - Send via NSAppleScript (in-process, no encoding issues)

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

// Make PirateRank comparable for rank change detection
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
