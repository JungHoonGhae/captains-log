import Foundation
import AppKit

struct RepoConfig: Codable {
    var repos: [String]
    var githubEnabled: Bool?
    var hasScannedOnce: Bool?
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

    var title: String { rawValue }

    var quote: String {
        switch self {
        case .captain:   return "Ye be a true Captain! The sea bows to ye!"
        case .firstMate: return "The sea be callin', mate... better start shippin'!"
        case .deckhand:  return "Ship's takin' water! Commit or walk the plank!"
        case .castaway:  return "Abandon ship! Ye be drownin'!"
        case .davyJones: return "To Davy Jones' Locker with ye! COMMIT NOW!"
        }
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

enum RepoActivity: Comparable {
    case active      // commit within 24h
    case recent      // commit within 7 days
    case stale       // commit within 30 days
    case dead        // no commit in 30+ days

    var label: String {
        switch self {
        case .active: return "Active"
        case .recent: return "Recent"
        case .stale:  return "Stale"
        case .dead:   return "Dead"
        }
    }

    var color: String {
        switch self {
        case .active: return "green"
        case .recent: return "yellow"
        case .stale:  return "orange"
        case .dead:   return "red"
        }
    }
}

struct RepoInfo: Identifiable {
    let path: String
    var lastCommit: Date?
    var todayCommits: Int = 0

    var id: String { path }
    var name: String { (path as NSString).lastPathComponent }

    var activity: RepoActivity {
        guard let last = lastCommit else { return .dead }
        let hours = Date().timeIntervalSince(last) / 3600
        switch hours {
        case ..<24:   return .active
        case ..<168:  return .recent   // 7 days
        case ..<720:  return .stale    // 30 days
        default:      return .dead
        }
    }

    var lastCommitText: String {
        guard let last = lastCommit else { return "No commits" }
        let seconds = Int(Date().timeIntervalSince(last))
        if seconds < 60 { return "Just now" }
        let minutes = seconds / 60
        if minutes < 60 { return "\(minutes)m ago" }
        let hours = minutes / 60
        if hours < 24 { return "\(hours)h ago" }
        let days = hours / 24
        if days < 30 { return "\(days)d ago" }
        let months = days / 30
        return "\(months)mo ago"
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

    private static let configPath = NSHomeDirectory() + "/.ship-or-die.json"

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

    var activeRepos: [RepoInfo] { repos.filter { $0.activity == .active } }
    var recentRepos: [RepoInfo] { repos.filter { $0.activity == .recent } }
    var staleRepos: [RepoInfo] { repos.filter { $0.activity == .stale } }
    var deadRepos: [RepoInfo] { repos.filter { $0.activity == .dead } }

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
    }

    func saveConfig() {
        let config = RepoConfig(repos: repoPaths, githubEnabled: githubEnabled, hasScannedOnce: hasScannedOnce)
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
        panel.message = "Select yer git repositories, Captain!"
        panel.prompt = "Add Repo"

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

            // Sort: active first, then by last commit (most recent first)
            repoInfos.sort { a, b in
                if a.activity != b.activity { return a.activity < b.activity }
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
        if seconds < 60 { return "Just now" }
        let minutes = seconds / 60
        if minutes < 60 { return "\(minutes)m ago" }
        let hours = minutes / 60
        if hours < 24 { return "\(hours)h ago" }
        let days = hours / 24
        if days < 30 { return "\(days)d ago" }
        let months = days / 30
        return "\(months)mo ago"
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
