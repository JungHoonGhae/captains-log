import Foundation
import AppKit
import ServiceManagement

enum Weather {
    case clear, cloudy, rainy, stormy, hurricane

    var emoji: String {
        switch self {
        case .clear:     return "\u{2600}\u{FE0F}"
        case .cloudy:    return "\u{26C5}"
        case .rainy:     return "\u{1F327}\u{FE0F}"
        case .stormy:    return "\u{26C8}\u{FE0F}"
        case .hurricane: return "\u{1F300}"
        }
    }

    var label: String { L10n.weatherLabel(self) }
}

enum VoyageRange: String, CaseIterable {
    case day = "1d"
    case threeDays = "3d"
    case week = "7d"
    case month = "30d"
    case year = "1y"

    var days: Int {
        switch self {
        case .day:       return 1
        case .threeDays: return 3
        case .week:      return 7
        case .month:     return 30
        case .year:      return 365
        }
    }

    var label: String {
        switch self {
        case .day:       return L10n.range1d
        case .threeDays: return L10n.range3d
        case .week:      return L10n.range7d
        case .month:     return L10n.range30d
        case .year:      return L10n.range1y
        }
    }
}

enum CardType: String, Codable, CaseIterable, Identifiable {
    case navigator, fleet, ships, coffee

    var id: String { rawValue }

    static let defaultOrder: [CardType] = [.navigator, .fleet, .ships, .coffee]
}

struct RepoConfig: Codable {
    var repos: [String]
    var githubEnabled: Bool?
    var hasScannedOnce: Bool?
    var language: String?
    var sleepEnabled: Bool?
    var sleepStart: Int?   // 0-23
    var sleepEnd: Int?     // 0-23
    var sleepDays: [Int]?  // 1=Sun, 2=Mon, ..., 7=Sat (Apple Calendar weekday)
    var shipViewStyle: String?
    var navigatorEnabled: Bool?
    var captainName: String?
    var cardOrder: [String]?
    var showWeather: Bool?
    var showChart: Bool?
    var showVoyage: Bool?
    var showTreasure: Bool?
    var showSpeechBubble: Bool?
    var dailyGoal: Int?
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

    static let allTypes: [ShipType] = [.flagship, .warship, .galleon, .sloop, .dinghy, .shipwreck]

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
    var dirtyFiles: Int = 0
    var unpushedCommits: Int = 0
    var flagshipGoal: Int = 5

    var id: String { path }
    var name: String { (path as NSString).lastPathComponent }

    var shipType: ShipType {
        guard let last = lastCommit else { return .shipwreck }
        let hours = Date().timeIntervalSince(last) / 3600
        if todayCommits >= flagshipGoal { return .flagship }
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

    // Weekly activity
    @Published var weeklyCommits: [Int] = Array(repeating: 0, count: 7)
    @Published var commitStreak: Int = 0

    // Voyage history (for arbitrary ranges)
    @Published var voyageData: [Int] = []
    @Published var voyageRange: VoyageRange = .week

    // GitHub
    @Published var githubEnabled: Bool = false
    @Published var githubUsername: String = ""
    @Published var githubLastPush: Date?
    @Published var githubTodayPushes: Int = 0
    @Published var githubConnected: Bool = false

    // Ship view style
    @Published var shipViewStyle: ShipViewStyle = .classic

    // Navigator
    @Published var navigatorEnabled: Bool = true
    @Published var totalDirtyFiles: Int = 0
    @Published var totalUnpushedCommits: Int = 0
    @Published var todayPushes: Int = 0

    // Captain name
    @Published var captainName: String = ""

    // Card order
    @Published var cardOrder: [CardType] = CardType.defaultOrder

    // Launch at login
    @Published var launchAtLogin: Bool = false

    // Navigator element toggles
    @Published var showWeather: Bool = true
    @Published var showChart: Bool = true
    @Published var showVoyage: Bool = true
    @Published var showTreasure: Bool = true
    @Published var showSpeechBubble: Bool = true

    // Daily commit goal
    @Published var dailyGoal: Int = 5

    // Sleep mode
    @Published var sleepEnabled: Bool = false
    @Published var sleepStart: Int = 23    // 0-23
    @Published var sleepEnd: Int = 7       // 0-23
    @Published var sleepDays: Set<Int> = Set(1...7)  // 1=Sun..7=Sat

    func setLaunchAtLogin(_ enabled: Bool) {
        launchAtLogin = enabled
        if enabled {
            try? SMAppService.mainApp.register()
        } else {
            try? SMAppService.mainApp.unregister()
        }
    }

    func toggleSleepDay(_ day: Int) {
        if sleepDays.contains(day) {
            sleepDays.remove(day)
        } else {
            sleepDays.insert(day)
        }
        saveConfig()
        refresh()
    }

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

    var isInSleepWindow: Bool {
        guard sleepEnabled else { return false }
        let cal = Calendar.current
        let now = Date()
        let weekday = cal.component(.weekday, from: now)
        guard sleepDays.contains(weekday) else { return false }
        let hour = cal.component(.hour, from: now)
        if sleepStart < sleepEnd {
            return hour >= sleepStart && hour < sleepEnd
        } else {
            return hour >= sleepStart || hour < sleepEnd
        }
    }

    var hullDots: Int {
        switch rank {
        case .captain:   return 5
        case .firstMate: return 4
        case .deckhand:  return 3
        case .castaway:  return 2
        case .davyJones: return 1
        }
    }

    var voyageProgress: Int { min(todayCommits, dailyGoal) }

    var inactivityStatus: String {
        guard let last = lastActivity else {
            return L10n.sunkTime("8h")
        }
        let minutes = Int(Date().timeIntervalSince(last) / 60)
        let timeStr: String
        if minutes < 60 {
            timeStr = "\(minutes)m"
        } else {
            let h = minutes / 60
            let m = minutes % 60
            timeStr = m > 0 ? "\(h)h\(m)m" : "\(h)h"
        }

        switch rank {
        case .captain, .firstMate:
            return L10n.anchoredTime(timeStr)
        case .deckhand:
            return L10n.driftingTime(timeStr)
        case .castaway:
            return L10n.floodingTime(timeStr)
        case .davyJones:
            return L10n.sunkTime(timeStr)
        }
    }

    var displayName: String { captainName.isEmpty ? "Captain" : captainName }

    var weather: Weather {
        switch waterLevel {
        case ..<20:  return .clear
        case ..<40:  return .cloudy
        case ..<60:  return .rainy
        case ..<80:  return .stormy
        default:     return .hurricane
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
        launchAtLogin = SMAppService.mainApp.status == .enabled
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
        navigatorEnabled = config.navigatorEnabled ?? true
        captainName = config.captainName ?? ""
        if let order = config.cardOrder {
            let parsed = order.compactMap { CardType(rawValue: $0) }
            let missing = CardType.defaultOrder.filter { !parsed.contains($0) }
            cardOrder = parsed + missing
        }
        sleepEnabled = config.sleepEnabled ?? false
        sleepStart = config.sleepStart ?? 23
        sleepEnd = config.sleepEnd ?? 7
        if let days = config.sleepDays {
            sleepDays = Set(days)
        }
        if let langStr = config.language, let lang = Language(rawValue: langStr) {
            L10n.lang = lang
        }
        if let styleStr = config.shipViewStyle, let style = ShipViewStyle(rawValue: styleStr) {
            shipViewStyle = style
        }
        showWeather = config.showWeather ?? true
        showChart = config.showChart ?? true
        showVoyage = config.showVoyage ?? true
        showTreasure = config.showTreasure ?? true
        showSpeechBubble = config.showSpeechBubble ?? true
        dailyGoal = config.dailyGoal ?? 5
    }

    func saveConfig() {
        let config = RepoConfig(repos: repoPaths, githubEnabled: githubEnabled, hasScannedOnce: hasScannedOnce, language: L10n.lang.rawValue, sleepEnabled: sleepEnabled, sleepStart: sleepStart, sleepEnd: sleepEnd, sleepDays: Array(sleepDays).sorted(), shipViewStyle: shipViewStyle.rawValue, navigatorEnabled: navigatorEnabled, captainName: captainName.isEmpty ? nil : captainName, cardOrder: cardOrder.map { $0.rawValue }, showWeather: showWeather, showChart: showChart, showVoyage: showVoyage, showTreasure: showTreasure, showSpeechBubble: showSpeechBubble, dailyGoal: dailyGoal)
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

            var sumDirty = 0
            var sumUnpushed = 0
            var sumTodayPushes = 0

            for path in repoPaths {
                var info = RepoInfo(path: path, flagshipGoal: dailyGoal)
                info.lastCommit = lastCommitDate(in: path)
                info.todayCommits = todayCommitCount(in: path)
                if navigatorEnabled {
                    info.dirtyFiles = dirtyFileCount(in: path)
                    info.unpushedCommits = unpushedCommitCount(in: path)
                    sumDirty += info.dirtyFiles
                    sumUnpushed += info.unpushedCommits
                    sumTodayPushes += todayPushedCommitCount(in: path)
                }
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

            // Weekly commits & streak
            fetchWeeklyCommits()
            fetchVoyageData()

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
                self.totalDirtyFiles = sumDirty
                self.totalUnpushedCommits = sumUnpushed
                self.todayPushes = sumTodayPushes
            }
        }
    }

    // MARK: - Weekly Commits

    private func fetchWeeklyCommits() {
        let cal = Calendar.current
        // Build 7 date boundaries: start of (today-6) ... start of (today) ... end of today
        let todayStart = cal.startOfDay(for: Date())
        var daily = Array(repeating: 0, count: 7)

        for path in repoPaths {
            // git log for the last 7 days
            let sinceDate = cal.date(byAdding: .day, value: -6, to: todayStart)!
            let sinceStr = ISO8601DateFormatter().string(from: sinceDate)
            let output = shell("git -C \"\(path)\" log --format=%ct --since=\"\(sinceStr)\" 2>/dev/null")
            let lines = output.split(separator: "\n")
            for line in lines {
                guard let ts = TimeInterval(line.trimmingCharacters(in: .whitespaces)) else { continue }
                let commitDate = Date(timeIntervalSince1970: ts)
                let dayOffset = cal.dateComponents([.day], from: cal.startOfDay(for: commitDate), to: todayStart).day ?? 0
                let index = 6 - dayOffset  // 0=6 days ago, 6=today
                if index >= 0 && index < 7 {
                    daily[index] += 1
                }
            }
        }

        // Calculate streak: consecutive days with commits, counting back from today
        var streak = 0
        for i in stride(from: 6, through: 0, by: -1) {
            if daily[i] > 0 {
                streak += 1
            } else {
                break
            }
        }

        DispatchQueue.main.async {
            self.weeklyCommits = daily
            self.commitStreak = streak
        }
    }

    // MARK: - Voyage History

    func fetchVoyageData(range: VoyageRange? = nil) {
        let r = range ?? voyageRange
        DispatchQueue.global(qos: .utility).async { [self] in
            let cal = Calendar.current

            if r == .day {
                // Hourly breakdown for today
                let todayStart = cal.startOfDay(for: Date())
                var hourly = Array(repeating: 0, count: 24)

                for path in repoPaths {
                    let sinceStr = ISO8601DateFormatter().string(from: todayStart)
                    let output = shell("git -C \"\(path)\" log --format=%ct --since=\"\(sinceStr)\" 2>/dev/null")
                    let lines = output.split(separator: "\n")
                    for line in lines {
                        guard let ts = TimeInterval(line.trimmingCharacters(in: .whitespaces)) else { continue }
                        let commitDate = Date(timeIntervalSince1970: ts)
                        let hour = cal.component(.hour, from: commitDate)
                        if hour >= 0 && hour < 24 {
                            hourly[hour] += 1
                        }
                    }
                }

                DispatchQueue.main.async {
                    self.voyageRange = r
                    self.voyageData = hourly
                }
            } else {
                // Daily breakdown
                let days = r.days
                let todayStart = cal.startOfDay(for: Date())
                var daily = Array(repeating: 0, count: days)

                for path in repoPaths {
                    let sinceDate = cal.date(byAdding: .day, value: -(days - 1), to: todayStart)!
                    let sinceStr = ISO8601DateFormatter().string(from: sinceDate)
                    let output = shell("git -C \"\(path)\" log --format=%ct --since=\"\(sinceStr)\" 2>/dev/null")
                    let lines = output.split(separator: "\n")
                    for line in lines {
                        guard let ts = TimeInterval(line.trimmingCharacters(in: .whitespaces)) else { continue }
                        let commitDate = Date(timeIntervalSince1970: ts)
                        let dayOffset = cal.dateComponents([.day], from: cal.startOfDay(for: commitDate), to: todayStart).day ?? 0
                        let index = (days - 1) - dayOffset
                        if index >= 0 && index < days {
                            daily[index] += 1
                        }
                    }
                }

                DispatchQueue.main.async {
                    self.voyageRange = r
                    self.voyageData = daily
                }
            }
        }
    }

    // MARK: - Water Level

    func calculateWaterLevel(lastActivity: Date?) -> Double {
        guard let last = lastActivity else { return 100 }
        let hours = adjustedInactiveHours(since: last)
        switch hours {
        case ..<1:   return max(0, hours / 1.0 * 20)
        case ..<2:   return 20 + (hours - 1) * 20
        case ..<4:   return 40 + (hours - 2) / 2.0 * 20
        case ..<8:   return 60 + (hours - 4) / 4.0 * 20
        default:     return 100
        }
    }

    /// Returns the number of inactive hours since `lastActivity`,
    /// subtracting any sleep-window hours that fall within that period.
    private func adjustedInactiveHours(since lastActivity: Date) -> Double {
        let now = Date()
        let totalSeconds = now.timeIntervalSince(lastActivity)
        guard sleepEnabled, totalSeconds > 0 else {
            return totalSeconds / 3600
        }

        let sleepSeconds = sleepSecondsBetween(from: lastActivity, to: now)
        return max(0, totalSeconds - sleepSeconds) / 3600
    }

    /// Counts total seconds that fall inside the daily sleep window
    /// between two dates. Handles overnight windows (e.g. 23:00–07:00).
    private func sleepSecondsBetween(from start: Date, to end: Date) -> Double {
        let cal = Calendar.current
        // Walk day-by-day from the date containing `start`
        var total: Double = 0
        var dayCursor = cal.startOfDay(for: start)
        let endDay = cal.startOfDay(for: end).addingTimeInterval(86400) // include last day

        while dayCursor < endDay {
            // Check if this day's weekday is in sleepDays
            let weekday = cal.component(.weekday, from: dayCursor)
            guard sleepDays.contains(weekday) else {
                dayCursor = dayCursor.addingTimeInterval(86400)
                continue
            }

            let windowStart: Date
            let windowEnd: Date

            if sleepStart < sleepEnd {
                // Same-day window, e.g. 1:00–6:00
                windowStart = cal.date(bySettingHour: sleepStart, minute: 0, second: 0, of: dayCursor)!
                windowEnd   = cal.date(bySettingHour: sleepEnd,   minute: 0, second: 0, of: dayCursor)!
            } else {
                // Overnight window, e.g. 23:00–07:00
                windowStart = cal.date(bySettingHour: sleepStart, minute: 0, second: 0, of: dayCursor)!
                windowEnd   = cal.date(bySettingHour: sleepEnd,   minute: 0, second: 0,
                                       of: dayCursor.addingTimeInterval(86400))!
            }

            // Clamp to [start, end]
            let overlapStart = max(windowStart, start)
            let overlapEnd   = min(windowEnd, end)
            if overlapStart < overlapEnd {
                total += overlapEnd.timeIntervalSince(overlapStart)
            }

            dayCursor = dayCursor.addingTimeInterval(86400)
        }
        return total
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

    private func dirtyFileCount(in repo: String) -> Int {
        let output = shell("git -C \"\(repo)\" status --porcelain 2>/dev/null | wc -l")
        return Int(output.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
    }

    private func unpushedCommitCount(in repo: String) -> Int {
        let output = shell("git -C \"\(repo)\" log @{u}.. --oneline 2>/dev/null | wc -l")
        return Int(output.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
    }

    private func todayPushedCommitCount(in repo: String) -> Int {
        let output = shell("git -C \"\(repo)\" log @{u} --since=midnight --oneline 2>/dev/null | wc -l")
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
