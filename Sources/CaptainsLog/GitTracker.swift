import Foundation
import AppKit

struct RepoConfig: Codable {
    var repos: [String]
    var githubEnabled: Bool?
    var hasScannedOnce: Bool?
    var language: String?
}

enum PirateRank: String {
    case captain    = "Captain"
    case firstMate  = "First Mate"
    case deckhand   = "Deckhand"
    case castaway   = "Castaway"
    case davyJones  = "Davy Jones"

    var emoji: String {
        switch self {
        case .captain:   return "🏴‍☠️"
        case .firstMate: return "⚓"
        case .deckhand:  return "🪝"
        case .castaway:  return "🏊"
        case .davyJones: return "☠️"
        }
    }

    var title: String { L10n.rankTitle(self) }

    var quote: String {
        L10n.rankQuote(self)
    }

    var sceneEmoji: String {
        switch self {
        case .captain:   return "🏴‍☠️"
        case .firstMate: return "⛵"
        case .deckhand:  return "🚣"
        case .castaway:  return "🏊"
        case .davyJones: return "💀"
        }
    }
}

enum ShipType: Int, Comparable {
    case flagship  = 0  // 5+ commits today — leading the fleet
    case warship   = 1  // active today
    case galleon   = 2  // active within 3 days
    case sloop     = 3  // active within 7 days
    case dinghy    = 4  // within 30 days
    case shipwreck = 5  // 30+ days — sunk

    static func < (lhs: ShipType, rhs: ShipType) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var emoji: String {
        switch self {
        case .flagship:  return "🚀"
        case .warship:   return "⚔️"
        case .galleon:   return "⛵"
        case .sloop:     return "🚣"
        case .dinghy:    return "⚓"
        case .shipwreck: return "💀"
        }
    }

    var label: String { L10n.shipLabel(self) }
    var description: String { L10n.shipDesc(self) }
}

struct RepoInfo: Identifiable {
    let path: String
    var lastCommit: Date?
    var todayCommits: Int = 0

    var id: String { path }
    var name: String { (path as NSString).lastPathComponent }

    var shipType: ShipType {
        guard let last = lastCommit else { return .shipwreck }
        let hours = Date().timeIntervalSince(last) / 3600
        if todayCommits >= 5 { return .flagship }
        if hours < 24 { return .warship }
        if hours < 72 { return .galleon }
        if hours < 168 { return .sloop }
        if hours < 720 { return .dinghy }
        return .shipwreck
    }

    var lastCommitText: String {
        guard let last = lastCommit else { return L10n.noCommits }
        let seconds = Int(Date().timeIntervalSince(last))
        if seconds < 60 { return L10n.justNow }
        let minutes = seconds / 60
        if minutes < 60 { return L10n.minutesAgo(minutes) }
        let hours = minutes / 60
        if hours < 24 { return L10n.hoursAgo(hours) }
        let days = hours / 24
        if days < 30 { return L10n.daysAgo(days) }
        let months = days / 30
        return L10n.monthsAgo(months)
    }
}

class GitTracker: ObservableObject {
    // Repos with activity info
    @Published var repos: [RepoInfo] = []
    @Published var repoPaths: [String] = []

    // Overall stats
    @Published var waterLevel: Double = 0
    @Published var lastCommitTime: Date?
    @Published var todayCommits: Int = 0
    @Published var lastActivity: Date?

    // GitHub
    @Published var githubEnabled: Bool = false
    @Published var githubUsername: String = ""
    @Published var githubLastPush: Date?
    @Published var githubTodayPushes: Int = 0
    @Published var githubConnected: Bool = false

    // Scan state
    @Published var isScanning: Bool = false
    private var hasScannedOnce: Bool = false

    private static let configPath = NSHomeDirectory() + "/.captains-log.json"

    var rank: PirateRank {
        switch waterLevel {
        case ..<20:  return .captain
        case ..<40:  return .firstMate
        case ..<60:  return .deckhand
        case ..<80:  return .castaway
        default:     return .davyJones
        }
    }

    var menuBarDisplay: String { rank.emoji }

    var timeSinceLastCommit: String { formatTimeAgo(lastCommitTime) }
    var timeSinceLastPush: String { formatTimeAgo(githubLastPush) }
    var timeSinceLastActivity: String { formatTimeAgo(lastActivity) }

    var flagships: [RepoInfo]  { repos.filter { $0.shipType == .flagship } }
    var warships: [RepoInfo]   { repos.filter { $0.shipType == .warship } }
    var galleons: [RepoInfo]   { repos.filter { $0.shipType == .galleon } }
    var sloops: [RepoInfo]     { repos.filter { $0.shipType == .sloop } }
    var dinghies: [RepoInfo]   { repos.filter { $0.shipType == .dinghy } }
    var shipwrecks: [RepoInfo] { repos.filter { $0.shipType == .shipwreck } }

    var sailingCount: Int { repos.filter { $0.shipType <= .sloop }.count }
    var fleetStrength: String {
        let sailing = sailingCount
        let total = repos.count
        guard total > 0 else { return L10n.noFleet }
        return L10n.fleetStrength(sailing, total)
    }

    init() {
        loadConfig()
    }

    // MARK: - Config

    func loadConfig() {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: Self.configPath)),
              let config = try? JSONDecoder().decode(RepoConfig.self, from: data) else {
            return
        }
        repoPaths = config.repos
        githubEnabled = config.githubEnabled ?? false
        hasScannedOnce = config.hasScannedOnce ?? false
        if let langStr = config.language, let lang = Language(rawValue: langStr) {
            L10n.lang = lang
        }
    }

    func saveConfig() {
        let config = RepoConfig(repos: repoPaths, githubEnabled: githubEnabled, hasScannedOnce: hasScannedOnce, language: L10n.lang.rawValue)
        guard let data = try? JSONEncoder().encode(config) else { return }
        try? data.write(to: URL(fileURLWithPath: Self.configPath))
    }

    func autoScanIfNeeded() {
        guard !hasScannedOnce else { return }
        scanForRepos()
    }

    func addRepo(_ path: String) {
        let expanded = (path as NSString).expandingTildeInPath
        guard !repoPaths.contains(expanded) else { return }
        let gitDir = expanded + "/.git"
        guard FileManager.default.fileExists(atPath: gitDir) else { return }
        repoPaths.append(expanded)
        saveConfig()
        refresh()
    }

    func removeRepo(_ path: String) {
        repoPaths.removeAll { $0 == path }
        saveConfig()
        refresh()
    }

    func pickRepoFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = true
        panel.message = L10n.selectRepos
        panel.prompt = L10n.addRepo

        if panel.runModal() == .OK {
            for url in panel.urls {
                addRepo(url.path)
            }
        }
    }

    func scanForRepos() {
        DispatchQueue.main.async { self.isScanning = true }

        DispatchQueue.global(qos: .utility).async { [self] in
            let home = NSHomeDirectory()
            let scanRoots = [
                home + "/Projects",
                home + "/Developer",
                home + "/Desktop",
                home + "/Documents",
                home + "/repos",
                home + "/src",
                home + "/code",
                home + "/work",
            ]

            var found: [String] = []
            let fm = FileManager.default

            func scanDir(_ dir: String, depth: Int) {
                guard depth > 0 else { return }
                guard fm.fileExists(atPath: dir) else { return }
                guard let contents = try? fm.contentsOfDirectory(atPath: dir) else { return }
                for item in contents {
                    guard !item.hasPrefix(".") else { continue }
                    let fullPath = dir + "/" + item
                    let gitPath = fullPath + "/.git"
                    if fm.fileExists(atPath: gitPath) {
                        if !repoPaths.contains(fullPath), !found.contains(fullPath) {
                            found.append(fullPath)
                        }
                    } else {
                        var isDir: ObjCBool = false
                        if fm.fileExists(atPath: fullPath, isDirectory: &isDir), isDir.boolValue {
                            scanDir(fullPath, depth: depth - 1)
                        }
                    }
                }
            }

            for root in scanRoots {
                scanDir(root, depth: 3)
            }

            DispatchQueue.main.async {
                if !found.isEmpty {
                    self.repoPaths.append(contentsOf: found)
                }
                self.hasScannedOnce = true
                self.saveConfig()
                self.isScanning = false
                self.refresh()
            }
        }
    }

    // MARK: - GitHub

    func detectGitHub() {
        DispatchQueue.global(qos: .utility).async { [self] in
            let ghPath = shell("which gh 2>/dev/null").trimmingCharacters(in: .whitespacesAndNewlines)
            guard !ghPath.isEmpty else {
                DispatchQueue.main.async { self.githubConnected = false }
                return
            }

            let status = shell("gh auth status 2>&1")
            guard status.contains("Logged in") else {
                DispatchQueue.main.async { self.githubConnected = false }
                return
            }

            let username = shell("gh api user --jq .login 2>/dev/null")
                .trimmingCharacters(in: .whitespacesAndNewlines)

            DispatchQueue.main.async {
                if !username.isEmpty {
                    self.githubUsername = username
                    self.githubConnected = true
                    self.githubEnabled = true
                    self.saveConfig()
                }
            }
        }
    }

    private func fetchGitHubActivity() {
        guard githubEnabled, !githubUsername.isEmpty else { return }

        let output = shell(
            "gh api \"users/\(githubUsername)/events?per_page=100\" --jq '[.[] | select(.type==\"PushEvent\") | .created_at]' 2>/dev/null"
        )

        guard let data = output.data(using: .utf8),
              let dateStrings = try? JSONSerialization.jsonObject(with: data) as? [String] else {
            return
        }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let fallback = ISO8601DateFormatter()

        let pushDates: [Date] = dateStrings.compactMap {
            formatter.date(from: $0) ?? fallback.date(from: $0)
        }

        self.githubLastPush = pushDates.first
        self.githubTodayPushes = pushDates.filter { Calendar.current.isDateInToday($0) }.count
    }

    // MARK: - Refresh

    func refresh() {
        DispatchQueue.global(qos: .utility).async { [self] in
            // Per-repo stats
            var repoInfos: [RepoInfo] = []
            var latestLocalCommit: Date?
            var totalTodayLocal = 0

            for path in repoPaths {
                var info = RepoInfo(path: path)
                info.lastCommit = lastCommitDate(in: path)
                info.todayCommits = todayCommitCount(in: path)
                repoInfos.append(info)

                if let commit = info.lastCommit {
                    if latestLocalCommit == nil || commit > latestLocalCommit! {
                        latestLocalCommit = commit
                    }
                }
                totalTodayLocal += info.todayCommits
            }

            // Sort: best ships first, then by last commit
            repoInfos.sort { a, b in
                if a.shipType != b.shipType { return a.shipType < b.shipType }
                guard let aDate = a.lastCommit else { return false }
                guard let bDate = b.lastCommit else { return true }
                return aDate > bDate
            }

            // GitHub
            fetchGitHubActivity()

            // Most recent from any source
            var mostRecent: Date?
            if let local = latestLocalCommit { mostRecent = local }
            if let push = githubLastPush {
                if mostRecent == nil || push > mostRecent! { mostRecent = push }
            }

            DispatchQueue.main.async {
                self.repos = repoInfos
                self.lastCommitTime = latestLocalCommit
                self.todayCommits = totalTodayLocal
                self.lastActivity = mostRecent
                self.waterLevel = self.calculateWaterLevel(lastActivity: mostRecent)
            }
        }
    }

    // MARK: - Water Level

    private func calculateWaterLevel(lastActivity: Date?) -> Double {
        guard let last = lastActivity else { return 100 }
        let hours = Date().timeIntervalSince(last) / 3600
        switch hours {
        case ..<1:   return max(0, hours / 1.0 * 20)
        case ..<2:   return 20 + (hours - 1) * 20
        case ..<4:   return 40 + (hours - 2) / 2.0 * 20
        case ..<8:   return 60 + (hours - 4) / 4.0 * 20
        default:     return 100
        }
    }

    // MARK: - Local Git

    private func lastCommitDate(in repo: String) -> Date? {
        let output = shell("git -C \"\(repo)\" log -1 --format=%ct 2>/dev/null")
        guard let ts = TimeInterval(output.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            return nil
        }
        return Date(timeIntervalSince1970: ts)
    }

    private func todayCommitCount(in repo: String) -> Int {
        let output = shell("git -C \"\(repo)\" log --since=midnight --oneline 2>/dev/null | wc -l")
        return Int(output.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
    }

    // MARK: - Helpers

    func formatTimeAgo(_ date: Date?) -> String {
        guard let date else { return "—" }
        let seconds = Int(Date().timeIntervalSince(date))
        if seconds < 60 { return L10n.justNow }
        let minutes = seconds / 60
        if minutes < 60 { return L10n.minutesAgo(minutes) }
        let hours = minutes / 60
        if hours < 24 { return L10n.hoursAgo(hours) }
        let days = hours / 24
        if days < 30 { return L10n.daysAgo(days) }
        let months = days / 30
        return L10n.monthsAgo(months)
    }

    private func shell(_ command: String) -> String {
        let process = Process()
        let pipe = Pipe()
        process.executableURL = URL(fileURLWithPath: "/bin/sh")
        process.arguments = ["-c", command]
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice
        try? process.run()
        process.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8) ?? ""
    }
}
