import SwiftUI

// MARK: - Card modifier

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.primary.opacity(0.04))
            )
    }
}

extension View {
    func card() -> some View { modifier(CardStyle()) }
}

// MARK: - Ship View Style

enum ShipViewStyle: String, CaseIterable, Codable {
    case classic, compact, grid, fleet

    var label: String {
        switch self {
        case .classic: return L10n.viewClassic
        case .compact: return L10n.viewCompact
        case .grid:    return L10n.viewGrid
        case .fleet:   return L10n.viewFleet
        }
    }

    var icon: String {
        switch self {
        case .classic: return "list.bullet"
        case .compact: return "list.dash"
        case .grid:    return "square.grid.2x2"
        case .fleet:   return "flag.2.crossed"
        }
    }
}

// MARK: - Navigation

enum Screen {
    case main, settings
}

// MARK: - Main View

struct ContentView: View {
    @ObservedObject var tracker: GitTracker
    @State private var showAllRepos = false
    @State private var screen: Screen = .main
    @State private var draggingCard: CardType?

    var body: some View {
        switch screen {
        case .main:
            mainView
        case .settings:
            SettingsView(tracker: tracker, screen: $screen)
        }
    }

    private var mainView: some View {
        ScrollView {
            VStack(spacing: 12) {
                header
                animation
                ForEach(tracker.cardOrder) { card in
                    cardView(for: card)
                        .opacity(draggingCard == card ? 0.4 : 1)
                        .onDrag {
                            draggingCard = card
                            return NSItemProvider(object: card.rawValue as NSString)
                        }
                        .onDrop(of: [.text], delegate: CardDropDelegate(
                            card: card,
                            tracker: tracker,
                            draggingCard: $draggingCard
                        ))
                }
            }
            .padding(14)
        }
        .frame(width: 320)
        .frame(maxHeight: 640)
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(tracker.captainName.isEmpty ? L10n.appTitle : "\(tracker.displayName)'s Log")
                    .font(.system(size: 13, weight: .semibold))
                HStack(spacing: 4) {
                    Image(systemName: rankIcon)
                        .font(.system(size: 9))
                        .foregroundColor(rankColor)
                    Text(tracker.rank.title)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(rankColor)
                    Text("·")
                        .foregroundColor(.secondary.opacity(0.4))
                    Text("\(tracker.weather.emoji) \(tracker.weather.label)")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            Text(tracker.fleetStrength)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Capsule().fill(Color.primary.opacity(0.05)))

            Button { screen = .settings } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary.opacity(0.6))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Animation

    private var animation: some View {
        WaterAnimationView(
            waterLevel: tracker.waterLevel,
            rank: tracker.rank,
            navigatorEnabled: tracker.navigatorEnabled,
            totalDirtyFiles: tracker.totalDirtyFiles,
            totalUnpushedCommits: tracker.totalUnpushedCommits,
            todayCommits: tracker.todayCommits,
            todayPushes: tracker.todayPushes,
            showSpeechBubble: tracker.showSpeechBubble
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Card Router

    @ViewBuilder
    private func cardView(for card: CardType) -> some View {
        switch card {
        case .navigator:
            if tracker.navigatorEnabled { navigatorCard }
        case .fleet:
            fleetCard
        case .ships:
            shipsCard
        case .coffee:
            coffeeButton
        }
    }

    // MARK: - Navigator Card

    private var navigatorCard: some View {
        let hullPercent = max(0, 100 - Int(tracker.waterLevel))

        return VStack(alignment: .leading, spacing: 10) {
            // Header: title + streak badge
            HStack {
                Label(L10n.navigator, systemImage: "safari.fill")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
                if tracker.commitStreak > 0 {
                    HStack(spacing: 3) {
                        Text("\u{1F525}")
                            .font(.system(size: 10))
                        Text(L10n.dSailing(tracker.commitStreak))
                            .font(.system(size: 9, weight: .semibold))
                    }
                    .foregroundColor(.orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(Color.orange.opacity(0.12)))
                }
            }

            // Sea Condition
            if tracker.showWeather {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(L10n.seaCondition)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(tracker.weather.emoji) \(L10n.hullStatus(tracker.rank))")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(weatherColor)
                        Text("\u{00B7}")
                            .font(.system(size: 9))
                            .foregroundColor(.secondary.opacity(0.4))
                        Text(tracker.inactivityStatus)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(weatherColor.opacity(0.8))
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.primary.opacity(0.06))
                            RoundedRectangle(cornerRadius: 3)
                                .fill(weatherColor)
                                .frame(width: geo.size.width * CGFloat(hullPercent) / 100)
                        }
                    }
                    .frame(height: 6)
                }
            }

            // Daily Goal
            if tracker.showVoyage {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(L10n.dailyGoal)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.secondary)
                        Spacer()
                        if tracker.todayCommits >= tracker.dailyGoal {
                            Text(L10n.flagship)
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundColor(.yellow)
                        } else {
                            Text("\(tracker.todayCommits) / \(tracker.dailyGoal)")
                                .font(.system(size: 9, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                    }
                    HStack(spacing: 6) {
                        ForEach(0..<tracker.dailyGoal, id: \.self) { i in
                            Circle()
                                .fill(i < tracker.todayCommits ? voyageDotColor(i) : Color.primary.opacity(0.08))
                                .frame(width: tracker.dailyGoal <= 10 ? 8 : 6, height: tracker.dailyGoal <= 10 ? 8 : 6)
                        }
                        if tracker.todayCommits > tracker.dailyGoal {
                            Text("+\(tracker.todayCommits - tracker.dailyGoal)")
                                .font(.system(size: 8, weight: .bold, design: .rounded))
                                .foregroundColor(.yellow)
                        }
                        Spacer()
                    }
                }
            }

            // Voyage Chart
            if tracker.showChart {
                voyageChartSection
            }

            // Treasure Status
            if tracker.showTreasure {
                Divider()
                PipelineView(dirtyFiles: tracker.totalDirtyFiles, todayCommits: tracker.todayCommits, todayPushes: tracker.todayPushes)
            }
        }
        .card()
    }

    private var weatherColor: Color {
        switch tracker.weather {
        case .clear:     return .green
        case .cloudy:    return .cyan
        case .rainy:     return .yellow
        case .stormy:    return .orange
        case .hurricane: return .red
        }
    }

    private func voyageDotColor(_ index: Int) -> Color {
        if tracker.todayCommits >= tracker.dailyGoal { return .yellow }
        return .cyan
    }

    // MARK: - Voyage Chart Section (inside Navigator)

    private var voyageChartSection: some View {
        let data = tracker.voyageData.isEmpty ? tracker.weeklyCommits : tracker.voyageData
        let days = data.count

        return VStack(alignment: .leading, spacing: 6) {
            Divider()

            // Range selector
            HStack(spacing: 0) {
                Text(L10n.voyageLog)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
                ForEach(VoyageRange.allCases, id: \.self) { range in
                    Button {
                        tracker.fetchVoyageData(range: range)
                    } label: {
                        Text(range.label)
                            .font(.system(size: 8, weight: tracker.voyageRange == range ? .bold : .medium))
                            .foregroundColor(tracker.voyageRange == range ? .white : .secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(tracker.voyageRange == range ? Color.accentColor : Color.clear)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }

            if data.allSatisfy({ $0 == 0 }) {
                Text(L10n.noVoyage)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary.opacity(0.5))
            } else {
                let maxCommit = max(data.max() ?? 1, 1)
                let bars = voyageBars(data: data, days: days)
                let isHourly = tracker.voyageRange == .day

                HStack(alignment: .bottom, spacing: isHourly ? 1 : (days <= 7 ? 6 : 2)) {
                    ForEach(Array(bars.enumerated()), id: \.offset) { idx, bar in
                        let barHeight: CGFloat = bar.count > 0
                            ? max(4, CGFloat(bar.count) / CGFloat(maxCommit) * 48)
                            : 2

                        VStack(spacing: 2) {
                            if bar.count > 0 && bars.count <= 7 {
                                Text("\(bar.count)")
                                    .font(.system(size: 7, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)
                            }

                            RoundedRectangle(cornerRadius: 2)
                                .fill(voyageBarColor(bar.count))
                                .frame(height: barHeight)

                            if bar.showLabel {
                                Text(bar.label)
                                    .font(.system(size: 6, weight: .medium))
                                    .foregroundColor(.secondary.opacity(0.6))
                                    .lineLimit(1)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 72)
            }
        }
    }

    // MARK: - Fleet Status Card

    private var fleetCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(L10n.fleet, systemImage: "sailboat.fill")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
                Text(tracker.timeSinceLastActivity)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary.opacity(0.6))
            }

            HStack(spacing: 0) {
                fleetStat(label: L10n.shipFlagship, count: tracker.flagships.count, color: .yellow)
                Spacer()
                fleetStat(label: L10n.shipWarship, count: tracker.warships.count, color: .green)
                Spacer()
                fleetStat(label: L10n.shipGalleon, count: tracker.galleons.count, color: .blue)
                Spacer()
                fleetStat(label: L10n.shipSloop, count: tracker.sloops.count, color: .cyan)
                Spacer()
                fleetStat(label: L10n.shipDinghy, count: tracker.dinghies.count, color: .orange)
                Spacer()
                fleetStat(label: L10n.shipShipwreck, count: tracker.shipwrecks.count, color: .red)
            }
        }
        .card()
    }

    private func fleetStat(label: String, count: Int, color: Color) -> some View {
        VStack(spacing: 3) {
            Text("\(count)")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(count > 0 ? color : .secondary.opacity(0.3))
            Text(label)
                .font(.system(size: 7, weight: .medium))
                .foregroundColor(.secondary.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }

    private struct VoyageBar {
        let count: Int
        let label: String
        let showLabel: Bool
    }

    private func voyageBars(data: [Int], days: Int) -> [VoyageBar] {
        let cal = Calendar.current
        let isHourly = tracker.voyageRange == .day

        if isHourly {
            // 24-hour view: show each hour, label every 6h
            return data.enumerated().map { hour, count in
                let showLabel = hour % 6 == 0 || hour == 23
                let label = showLabel ? String(format: "%02d", hour) : ""
                return VoyageBar(count: count, label: label, showLabel: showLabel)
            }
        } else if days <= 7 {
            return data.enumerated().map { i, count in
                let daysAgo = (days - 1) - i
                let date = cal.date(byAdding: .day, value: -daysAgo, to: Date())!
                let weekday = cal.component(.weekday, from: date)
                return VoyageBar(count: count, label: L10n.dayAbbrev(weekday), showLabel: true)
            }
        } else if days <= 30 {
            return data.enumerated().map { i, count in
                let daysAgo = (days - 1) - i
                let date = cal.date(byAdding: .day, value: -daysAgo, to: Date())!
                let day = cal.component(.day, from: date)
                let showLabel = i == 0 || i == days - 1 || i % 7 == 0
                return VoyageBar(count: count, label: showLabel ? "\(day)" : "", showLabel: showLabel)
            }
        } else {
            let weeksCount = (days + 6) / 7
            var weeks: [VoyageBar] = []
            for w in 0..<weeksCount {
                let start = w * 7
                let end = min(start + 7, days)
                let sum = data[start..<end].reduce(0, +)
                let daysAgo = (days - 1) - start
                let date = cal.date(byAdding: .day, value: -daysAgo, to: Date())!
                let month = cal.component(.month, from: date)
                let showLabel = w == 0 || w == weeksCount - 1 || w % 4 == 0
                let monthNames = ["", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
                let label = showLabel ? monthNames[month] : ""
                weeks.append(VoyageBar(count: sum, label: label, showLabel: showLabel))
            }
            return weeks
        }
    }

    private func voyageBarColor(_ count: Int) -> Color {
        switch count {
        case 0:     return .gray.opacity(0.2)
        case 1...2: return .cyan
        case 3...4: return .green
        default:    return .yellow
        }
    }

    // MARK: - Ships Card

    private var shipsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(L10n.ships, systemImage: "list.bullet")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
                if tracker.isScanning {
                    ProgressView().scaleEffect(0.4)
                } else {
                    Button { tracker.scanForRepos() } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 9))
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.secondary)

                    Button { tracker.pickRepoFolder() } label: {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 9))
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.secondary)
                }
            }

            if tracker.repos.isEmpty {
                Text(L10n.scanning)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary.opacity(0.5))
            } else {
                let displayed = showAllRepos ? tracker.repos : Array(tracker.repos.prefix(8))

                switch tracker.shipViewStyle {
                case .classic:
                    VStack(spacing: 0) {
                        ForEach(Array(displayed.enumerated()), id: \.element.id) { index, repo in
                            if index > 0 {
                                Divider().padding(.leading, 24)
                            }
                            shipRow(repo)
                        }
                    }
                case .compact:
                    compactShipList(displayed)
                case .grid:
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 6), GridItem(.flexible(), spacing: 6)], spacing: 6) {
                        ForEach(displayed) { repo in
                            gridShipCell(repo)
                        }
                    }
                case .fleet:
                    fleetShipView(displayed)
                }

                if tracker.repos.count > 8 {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { showAllRepos.toggle() }
                    } label: {
                        Text(showAllRepos ? L10n.showLess : L10n.showAll(tracker.repos.count))
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.accentColor)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)
                }
            }
        }
        .card()
    }

    private func shipRow(_ repo: RepoInfo) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(shipDotColor(repo.shipType))
                .frame(width: 6, height: 6)

            VStack(alignment: .leading, spacing: 0) {
                Text(repo.name)
                    .font(.system(size: 11, weight: repo.shipType <= .warship ? .medium : .regular))
                    .foregroundColor(repo.shipType == .shipwreck ? .secondary.opacity(0.4) : .primary)
                    .lineLimit(1)
                Text(repo.shipType.label)
                    .font(.system(size: 8))
                    .foregroundColor(shipDotColor(repo.shipType).opacity(0.7))
            }

            Spacer()

            dirtyIndicators(repo)

            Text(repo.lastCommitText)
                .font(.system(size: 9))
                .foregroundColor(.secondary.opacity(0.5))

            if repo.todayCommits > 0 {
                Text("\(repo.todayCommits)")
                    .font(.system(size: 9, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(minWidth: 16)
                    .padding(.horizontal, 3)
                    .padding(.vertical, 1)
                    .background(Capsule().fill(shipDotColor(repo.shipType)))
            }

            Button {
                tracker.removeRepo(repo.path)
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.secondary.opacity(0.25))
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 5)
    }

    // MARK: - Compact View (horizontal chip rows by type)

    private func compactShipList(_ repos: [RepoInfo]) -> some View {
        let grouped: [(ShipType, [RepoInfo])] = ShipType.allTypes.compactMap { type in
            let items = repos.filter { $0.shipType == type }
            return items.isEmpty ? nil : (type, items)
        }
        return VStack(alignment: .leading, spacing: 6) {
            ForEach(grouped, id: \.0) { type, items in
                HStack(spacing: 4) {
                    Text(type.emoji)
                        .font(.system(size: 10))
                    ForEach(items) { repo in
                        HStack(spacing: 2) {
                            Text(repo.name)
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(repo.shipType == .shipwreck ? .secondary.opacity(0.5) : .primary)
                                .lineLimit(1)
                            if tracker.navigatorEnabled {
                                if repo.dirtyFiles > 0 {
                                    Circle().fill(Color.orange).frame(width: 4, height: 4)
                                }
                                if repo.unpushedCommits > 0 {
                                    Circle().fill(Color.cyan).frame(width: 4, height: 4)
                                }
                            }
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(shipDotColor(type).opacity(0.12)))
                    }
                }
            }
        }
    }

    // MARK: - Grid View (2-col cards with color accent)

    private func gridShipCell(_ repo: RepoInfo) -> some View {
        let color = shipDotColor(repo.shipType)
        return VStack(spacing: 3) {
            HStack(spacing: 0) {
                Spacer()
                Text(repo.shipType.emoji)
                    .font(.system(size: 22))
                Spacer()
            }
            Text(repo.name)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(repo.shipType == .shipwreck ? .secondary.opacity(0.4) : .primary)
                .lineLimit(1)
            HStack(spacing: 4) {
                dirtyIndicators(repo)
                Text(repo.lastCommitText)
                    .font(.system(size: 8))
                    .foregroundColor(.secondary.opacity(0.5))
                if repo.todayCommits > 0 {
                    Text("\(repo.todayCommits)")
                        .font(.system(size: 8, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(Capsule().fill(color))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(color.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .strokeBorder(color.opacity(0.15), lineWidth: 1)
        )
    }

    // MARK: - Fleet View (grouped by ship type with headers)

    private func fleetShipView(_ repos: [RepoInfo]) -> some View {
        let grouped: [(ShipType, [RepoInfo])] = ShipType.allTypes.compactMap { type in
            let items = repos.filter { $0.shipType == type }
            return items.isEmpty ? nil : (type, items)
        }
        return VStack(alignment: .leading, spacing: 10) {
            ForEach(grouped, id: \.0) { type, items in
                VStack(alignment: .leading, spacing: 4) {
                    // Section header
                    HStack(spacing: 4) {
                        Text(type.emoji)
                            .font(.system(size: 11))
                        Text(type.label)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(shipDotColor(type))
                        Text("(\(items.count))")
                            .font(.system(size: 9))
                            .foregroundColor(.secondary.opacity(0.5))
                        Spacer()
                        Text(type.description)
                            .font(.system(size: 8))
                            .foregroundColor(.secondary.opacity(0.4))
                    }

                    // Ships in this group
                    ForEach(items) { repo in
                        HStack(spacing: 6) {
                            RoundedRectangle(cornerRadius: 1.5)
                                .fill(shipDotColor(type))
                                .frame(width: 3, height: 18)
                            dirtyIndicators(repo)
                            Text(repo.name)
                                .font(.system(size: 10))
                                .foregroundColor(type == .shipwreck ? .secondary.opacity(0.4) : .primary)
                                .lineLimit(1)
                            Spacer()
                            if repo.todayCommits > 0 {
                                Text("\(repo.todayCommits)")
                                    .font(.system(size: 8, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 1)
                                    .background(Capsule().fill(shipDotColor(type)))
                            }
                            Text(repo.lastCommitText)
                                .font(.system(size: 8))
                                .foregroundColor(.secondary.opacity(0.5))
                        }
                        .padding(.leading, 4)
                    }
                }
                .padding(6)
                .background(RoundedRectangle(cornerRadius: 6).fill(shipDotColor(type).opacity(0.04)))
            }
        }
    }

    // MARK: - Navigator Dirty Indicators

    @ViewBuilder
    private func dirtyIndicators(_ repo: RepoInfo) -> some View {
        if tracker.navigatorEnabled && (repo.dirtyFiles > 0 || repo.unpushedCommits > 0) {
            HStack(spacing: 3) {
                if repo.dirtyFiles > 0 {
                    Text("\u{1F48E}\(repo.dirtyFiles)")
                        .font(.system(size: 8, weight: .medium, design: .rounded))
                        .foregroundColor(.orange)
                }
                if repo.unpushedCommits > 0 {
                    Text("\u{1F4E6}\(repo.unpushedCommits)")
                        .font(.system(size: 8, weight: .medium, design: .rounded))
                        .foregroundColor(.cyan)
                }
            }
        }
    }

    // MARK: - Support

    private var coffeeButton: some View {
        Button {
            if let url = URL(string: "https://www.buymeacoffee.com/lucas.ghae") {
                NSWorkspace.shared.open(url)
            }
        } label: {
            HStack(spacing: 6) {
                Text("\u{2615}")
                    .font(.system(size: 13))
                Text("Buy me a coffee")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Colors

    private func shipDotColor(_ type: ShipType) -> Color {
        switch type {
        case .flagship:  return .yellow
        case .warship:   return .green
        case .galleon:   return .blue
        case .sloop:     return .cyan
        case .dinghy:    return .orange
        case .shipwreck: return .red.opacity(0.5)
        }
    }

    private var rankColor: Color {
        switch tracker.rank {
        case .captain:   return .green
        case .firstMate: return .blue
        case .deckhand:  return .orange
        case .castaway:  return .red
        case .davyJones: return .red
        }
    }

    private var rankIcon: String {
        switch tracker.rank {
        case .captain:   return "star.fill"
        case .firstMate: return "shield.fill"
        case .deckhand:  return "wrench.fill"
        case .castaway:  return "exclamationmark.triangle.fill"
        case .davyJones: return "xmark.seal.fill"
        }
    }

    private var levelColor: Color {
        switch tracker.waterLevel {
        case ..<25:  return .green
        case ..<50:  return .yellow
        case ..<75:  return .orange
        default:     return .red
        }
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @ObservedObject var tracker: GitTracker
    @Binding var screen: Screen

    // Mon(2)..Sun(1) display order → Apple weekday values
    private static let dayOrder: [Int] = [2, 3, 4, 5, 6, 7, 1]

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                settingsHeader
                generalSection
                featuresSection
                sleepSection
                footerSection
            }
            .padding(14)
        }
        .frame(width: 320)
        .frame(maxHeight: 640)
    }

    private var settingsHeader: some View {
        HStack {
            Button { screen = .main } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 10, weight: .semibold))
                    Text(L10n.settings)
                        .font(.system(size: 13, weight: .semibold))
                }
            }
            .buttonStyle(.plain)
            .foregroundColor(.primary)
            Spacer()
        }
    }

    // MARK: - General

    private var generalSection: some View {
        VStack(spacing: 0) {
            sectionHeader(L10n.general, icon: "gearshape")

            // Captain Name
            settingsRow {
                Label(L10n.captainName, systemImage: "person.fill")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
                TextField(L10n.captainNamePlaceholder, text: Binding(
                    get: { tracker.captainName },
                    set: {
                        tracker.captainName = $0
                        tracker.saveConfig()
                    }
                ))
                .font(.system(size: 11))
                .textFieldStyle(.plain)
                .frame(width: 120)
                .multilineTextAlignment(.trailing)
            }

            Divider().padding(.leading, 28)

            // Language
            settingsRow {
                Label(L10n.language, systemImage: "globe")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
                Picker("", selection: Binding(
                    get: { L10n.lang },
                    set: { newLang in
                        L10n.lang = newLang
                        tracker.saveConfig()
                        tracker.objectWillChange.send()
                    }
                )) {
                    ForEach(Language.allCases, id: \.self) { lang in
                        Text("\(lang.flag) \(lang.displayName)").tag(lang)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 130)
            }

            Divider().padding(.leading, 28)

            // Ship View
            settingsRow {
                Label(L10n.shipView, systemImage: "square.grid.2x2")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
                Picker("", selection: Binding(
                    get: { tracker.shipViewStyle },
                    set: { newStyle in
                        tracker.shipViewStyle = newStyle
                        tracker.saveConfig()
                        tracker.objectWillChange.send()
                    }
                )) {
                    ForEach(ShipViewStyle.allCases, id: \.self) { style in
                        Label(style.label, systemImage: style.icon).tag(style)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 130)
            }

            Divider().padding(.leading, 28)

            // Speech Bubble
            settingsRow {
                Label(L10n.speechBubble, systemImage: "bubble.left.fill")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
                Toggle("", isOn: Binding(
                    get: { tracker.showSpeechBubble },
                    set: { tracker.showSpeechBubble = $0; tracker.saveConfig() }
                ))
                .toggleStyle(.switch)
                .scaleEffect(0.55)
                .frame(width: 36)
            }

            Divider().padding(.leading, 28)

            // Daily Goal
            settingsRow {
                Label(L10n.dailyGoal, systemImage: "target")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
                HStack(spacing: 6) {
                    Button {
                        if tracker.dailyGoal > 1 {
                            tracker.dailyGoal -= 1
                            tracker.saveConfig()
                            tracker.refresh()
                        }
                    } label: {
                        Image(systemName: "minus.circle")
                            .font(.system(size: 12))
                            .foregroundColor(tracker.dailyGoal > 1 ? .secondary : .secondary.opacity(0.2))
                    }
                    .buttonStyle(.plain)

                    Text("\(tracker.dailyGoal) \(L10n.commits)")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .frame(minWidth: 55)

                    Button {
                        if tracker.dailyGoal < 20 {
                            tracker.dailyGoal += 1
                            tracker.saveConfig()
                            tracker.refresh()
                        }
                    } label: {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 12))
                            .foregroundColor(tracker.dailyGoal < 20 ? .secondary : .secondary.opacity(0.2))
                    }
                    .buttonStyle(.plain)
                }
            }

            if tracker.githubConnected {
                Divider().padding(.leading, 28)

                // GitHub
                settingsRow {
                    Label(L10n.github, systemImage: "person.circle.fill")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(tracker.githubUsername)
                        .font(.system(size: 9))
                        .foregroundColor(.secondary.opacity(0.5))
                    Toggle("", isOn: Binding(
                        get: { tracker.githubEnabled },
                        set: {
                            tracker.githubEnabled = $0
                            tracker.saveConfig()
                            tracker.refresh()
                        }
                    ))
                    .toggleStyle(.switch)
                    .scaleEffect(0.55)
                    .frame(width: 36)
                }
            }

            Divider().padding(.leading, 28)

            // Launch at Login
            settingsRow {
                Label(L10n.launchAtLogin, systemImage: "power")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
                Toggle("", isOn: Binding(
                    get: { tracker.launchAtLogin },
                    set: { tracker.setLaunchAtLogin($0) }
                ))
                .toggleStyle(.switch)
                .scaleEffect(0.55)
                .frame(width: 36)
            }
        }
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.primary.opacity(0.04)))
    }

    // MARK: - Navigator

    private var featuresSection: some View {
        VStack(spacing: 0) {
            // Navigator header with integrated toggle
            HStack(spacing: 8) {
                Image(systemName: "safari.fill")
                    .font(.system(size: 9))
                Text(L10n.navigator)
                    .font(.system(size: 10, weight: .semibold))
                Spacer()
                Toggle("", isOn: Binding(
                    get: { tracker.navigatorEnabled },
                    set: {
                        tracker.navigatorEnabled = $0
                        tracker.saveConfig()
                        tracker.refresh()
                    }
                ))
                .toggleStyle(.switch)
                .scaleEffect(0.55)
                .frame(width: 36)
            }
            .foregroundColor(.secondary.opacity(0.6))
            .padding(.horizontal, 10)
            .padding(.top, 8)
            .padding(.bottom, 4)

            if tracker.navigatorEnabled {
                navigatorToggle(L10n.seaCondition, icon: "cloud.sun.fill", binding: Binding(
                    get: { tracker.showWeather },
                    set: { tracker.showWeather = $0; tracker.saveConfig() }
                ))
                navigatorToggle(L10n.dailyGoal, icon: "flag.fill", binding: Binding(
                    get: { tracker.showVoyage },
                    set: { tracker.showVoyage = $0; tracker.saveConfig() }
                ))
                navigatorToggle(L10n.voyageLog, icon: "chart.bar.fill", binding: Binding(
                    get: { tracker.showChart },
                    set: { tracker.showChart = $0; tracker.saveConfig() }
                ))
                navigatorToggle(L10n.treasure, icon: "diamond.fill", binding: Binding(
                    get: { tracker.showTreasure },
                    set: { tracker.showTreasure = $0; tracker.saveConfig() }
                ))
            }
        }
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.primary.opacity(0.04)))
    }

    // MARK: - Sleep / Off Duty

    private var sleepSection: some View {
        VStack(spacing: 0) {
            sectionHeader(L10n.sleepMode, icon: "anchor.circle.fill")

            settingsRow {
                Label(L10n.sleepMode, systemImage: "moon.fill")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
                Toggle("", isOn: Binding(
                    get: { tracker.sleepEnabled },
                    set: {
                        tracker.sleepEnabled = $0
                        tracker.saveConfig()
                        tracker.refresh()
                    }
                ))
                .toggleStyle(.switch)
                .scaleEffect(0.55)
                .frame(width: 36)
            }

            if tracker.sleepEnabled {
                Divider().padding(.leading, 28)

                VStack(spacing: 8) {
                    HStack(spacing: 6) {
                        Text(L10n.sleepFrom)
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        Picker("", selection: Binding(
                            get: { tracker.sleepStart },
                            set: {
                                tracker.sleepStart = $0
                                tracker.saveConfig()
                                tracker.refresh()
                            }
                        )) {
                            ForEach(0..<24, id: \.self) { h in
                                Text(L10n.sleepHour(h)).tag(h)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(width: 82)

                        Text(L10n.sleepTo)
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        Picker("", selection: Binding(
                            get: { tracker.sleepEnd },
                            set: {
                                tracker.sleepEnd = $0
                                tracker.saveConfig()
                                tracker.refresh()
                            }
                        )) {
                            ForEach(0..<24, id: \.self) { h in
                                Text(L10n.sleepHour(h)).tag(h)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(width: 82)
                    }

                    HStack(spacing: 4) {
                        ForEach(Self.dayOrder, id: \.self) { weekday in
                            let isActive = tracker.sleepDays.contains(weekday)
                            Button {
                                tracker.toggleSleepDay(weekday)
                            } label: {
                                Text(L10n.dayAbbrev(weekday))
                                    .font(.system(size: 9, weight: .medium))
                                    .frame(width: 32, height: 24)
                                    .background(
                                        RoundedRectangle(cornerRadius: 5)
                                            .fill(isActive ? Color.accentColor.opacity(0.15) : Color.primary.opacity(0.04))
                                    )
                                    .foregroundColor(isActive ? .accentColor : .secondary.opacity(0.5))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
            }
        }
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.primary.opacity(0.04)))
    }

    // MARK: - Footer

    private var footerSection: some View {
        VStack(spacing: 6) {
            Button {
                if let url = URL(string: "https://www.buymeacoffee.com/lucas.ghae") {
                    NSWorkspace.shared.open(url)
                }
            } label: {
                HStack(spacing: 6) {
                    Text("\u{2615}")
                        .font(.system(size: 13))
                    Text("Buy me a coffee")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary.opacity(0.6))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
            }
            .buttonStyle(.plain)

            Button("\(L10n.quit) \(L10n.appTitle)") {
                NSApplication.shared.terminate(nil)
            }
            .font(.system(size: 10))
            .foregroundColor(.secondary.opacity(0.5))
            .buttonStyle(.plain)
        }
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 9))
            Text(title)
                .font(.system(size: 10, weight: .semibold))
        }
        .foregroundColor(.secondary.opacity(0.6))
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    private func settingsRow<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: 8) {
            content()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
    }

    private func navigatorToggle(_ label: String, icon: String, binding: Binding<Bool>) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 9))
                .foregroundColor(.secondary.opacity(0.5))
                .frame(width: 16)
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.secondary.opacity(0.7))
            Spacer()
            Toggle("", isOn: binding)
                .toggleStyle(.switch)
                .scaleEffect(0.5)
                .frame(width: 32)
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 3)
    }
}

// MARK: - Card Drag & Drop

struct CardDropDelegate: DropDelegate {
    let card: CardType
    let tracker: GitTracker
    @Binding var draggingCard: CardType?

    func performDrop(info: DropInfo) -> Bool {
        draggingCard = nil
        return true
    }

    func dropEntered(info: DropInfo) {
        guard let dragging = draggingCard, dragging != card else { return }
        guard let fromIndex = tracker.cardOrder.firstIndex(of: dragging),
              let toIndex = tracker.cardOrder.firstIndex(of: card) else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            tracker.cardOrder.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
        }
        tracker.saveConfig()
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
}
