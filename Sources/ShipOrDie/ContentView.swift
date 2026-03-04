import SwiftUI

struct ContentView: View {
    @ObservedObject var tracker: GitTracker
    @State private var showAllRepos = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            header
            WaterAnimationView(waterLevel: tracker.waterLevel, rank: tracker.rank)
            pirateQuote
            Divider()
            activityStats
            if tracker.githubConnected {
                Divider()
                githubSection
            }
            Divider()
            repoSection
            Divider()
            footer
        }
        .padding()
        .frame(width: 320)
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Ship or Die")
                    .font(.system(size: 14, weight: .bold))
                HStack(spacing: 4) {
                    Text(tracker.rank.emoji)
                        .font(.system(size: 11))
                    Text(tracker.rank.title)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(Int(tracker.waterLevel))%")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(levelColor)
                Text("water level")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
            }
        }
    }

    private var pirateQuote: some View {
        Text(tracker.rank.quote)
            .font(.system(size: 10, design: .serif))
            .italic()
            .foregroundColor(.secondary)
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Activity Stats

    private var activityStats: some View {
        HStack {
            Label {
                Text("Last Activity")
                    .font(.caption2)
            } icon: {
                Image(systemName: "clock")
                    .font(.caption2)
            }
            .foregroundColor(.secondary)
            Spacer()
            Text(tracker.timeSinceLastActivity)
                .font(.system(size: 11, weight: .medium))
        }
    }

    // MARK: - GitHub

    private var githubSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack(spacing: 4) {
                    Circle().fill(Color.green).frame(width: 6, height: 6)
                    Text("GitHub: \(tracker.githubUsername)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Toggle("", isOn: Binding(
                    get: { tracker.githubEnabled },
                    set: {
                        tracker.githubEnabled = $0
                        tracker.saveConfig()
                        tracker.refresh()
                    }
                ))
                .toggleStyle(.switch)
                .scaleEffect(0.65)
            }
            HStack {
                statBox(label: "Last Push", value: tracker.timeSinceLastPush)
                Spacer()
                statBox(label: "Today Pushes", value: "\(tracker.githubTodayPushes)")
                Spacer()
                statBox(label: "Today Local", value: "\(tracker.todayCommits)")
            }
        }
    }

    private func statBox(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 9))
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 11, weight: .medium))
        }
    }

    // MARK: - Repos

    private var repoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header row
            HStack {
                Text("Repos (\(tracker.repos.count))")
                    .font(.system(size: 11, weight: .semibold))
                Spacer()
                if tracker.isScanning {
                    ProgressView()
                        .scaleEffect(0.5)
                        .frame(width: 12, height: 12)
                    Text("Scanning...")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                } else {
                    Button("Scan") { tracker.scanForRepos() }
                        .font(.system(size: 10))
                    Button("Browse...") { tracker.pickRepoFolder() }
                        .font(.system(size: 10))
                }
            }

            // Activity summary badges
            if !tracker.repos.isEmpty {
                HStack(spacing: 6) {
                    activityBadge(count: tracker.activeRepos.count, label: "Active", color: .green)
                    activityBadge(count: tracker.recentRepos.count, label: "Recent", color: .yellow)
                    activityBadge(count: tracker.staleRepos.count, label: "Stale", color: .orange)
                    activityBadge(count: tracker.deadRepos.count, label: "Dead", color: .red)
                }
            }

            // Repo list
            if tracker.repos.isEmpty {
                Text("No repos tracked yet. Scanning on first launch...")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary.opacity(0.6))
                    .italic()
            } else {
                let displayed = showAllRepos ? tracker.repos : Array(tracker.repos.prefix(8))

                VStack(spacing: 2) {
                    ForEach(displayed) { repo in
                        repoRow(repo)
                    }
                }

                if tracker.repos.count > 8 {
                    Button(showAllRepos ? "Show less" : "Show all \(tracker.repos.count) repos...") {
                        showAllRepos.toggle()
                    }
                    .font(.system(size: 9))
                    .foregroundColor(.blue)
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func activityBadge(count: Int, label: String, color: Color) -> some View {
        HStack(spacing: 3) {
            Circle().fill(color).frame(width: 5, height: 5)
            Text("\(count)")
                .font(.system(size: 10, weight: .bold))
            Text(label)
                .font(.system(size: 9))
                .foregroundColor(.secondary)
        }
    }

    private func repoRow(_ repo: RepoInfo) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(activityColor(repo.activity))
                .frame(width: 6, height: 6)

            Text(repo.name)
                .font(.system(size: 10, weight: repo.activity == .active ? .medium : .regular))
                .foregroundColor(repo.activity == .dead ? .secondary.opacity(0.5) : .primary)
                .lineLimit(1)

            Spacer()

            Text(repo.lastCommitText)
                .font(.system(size: 9))
                .foregroundColor(.secondary)

            if repo.todayCommits > 0 {
                Text("\(repo.todayCommits)")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 1)
                    .background(Capsule().fill(Color.green))
            }

            Button {
                tracker.removeRepo(repo.path)
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 7))
                    .foregroundColor(.secondary.opacity(0.4))
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 1)
    }

    private func activityColor(_ activity: RepoActivity) -> Color {
        switch activity {
        case .active: return .green
        case .recent: return .yellow
        case .stale:  return .orange
        case .dead:   return .red
        }
    }

    // MARK: - Footer

    private var footer: some View {
        HStack {
            Button("Quit") { NSApplication.shared.terminate(nil) }
                .font(.system(size: 10))
                .foregroundColor(.secondary)
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
