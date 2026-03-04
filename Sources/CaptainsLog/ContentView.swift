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

// MARK: - Main View

struct ContentView: View {
    @ObservedObject var tracker: GitTracker
    @State private var showAllRepos = false

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                header
                animation
                fleetCard
                if tracker.githubConnected { githubCard }
                shipsCard
                quitRow
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
                Text("Captain's Log")
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
                    Text("\(Int(tracker.waterLevel))% water")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            // Fleet strength pill
            Text(tracker.fleetStrength)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Capsule().fill(Color.primary.opacity(0.05)))
        }
    }

    // MARK: - Animation

    private var animation: some View {
        WaterAnimationView(waterLevel: tracker.waterLevel, rank: tracker.rank)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Fleet Status Card

    private var fleetCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Fleet", systemImage: "sailboat.fill")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
                Text(tracker.timeSinceLastActivity)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary.opacity(0.6))
            }

            HStack(spacing: 0) {
                fleetStat(label: "Flagship", count: tracker.flagships.count, color: .yellow)
                Spacer()
                fleetStat(label: "Warship", count: tracker.warships.count, color: .green)
                Spacer()
                fleetStat(label: "Galleon", count: tracker.galleons.count, color: .blue)
                Spacer()
                fleetStat(label: "Sloop", count: tracker.sloops.count, color: .cyan)
                Spacer()
                fleetStat(label: "Docked", count: tracker.dinghies.count, color: .orange)
                Spacer()
                fleetStat(label: "Sunk", count: tracker.shipwrecks.count, color: .red)
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

    // MARK: - GitHub Card

    private var githubCard: some View {
        HStack(spacing: 10) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 14))
                .foregroundColor(.secondary.opacity(0.5))

            VStack(alignment: .leading, spacing: 1) {
                Text(tracker.githubUsername)
                    .font(.system(size: 11, weight: .medium))
                Text(tracker.timeSinceLastPush)
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 1) {
                Text("\(tracker.githubTodayPushes)")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                Text("pushes")
                    .font(.system(size: 8))
                    .foregroundColor(.secondary)
            }

            VStack(alignment: .trailing, spacing: 1) {
                Text("\(tracker.todayCommits)")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                Text("local")
                    .font(.system(size: 8))
                    .foregroundColor(.secondary)
            }

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
        .card()
    }

    // MARK: - Ships Card

    private var shipsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Ships", systemImage: "list.bullet")
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
                Text("Scanning for repos...")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary.opacity(0.5))
            } else {
                let displayed = showAllRepos ? tracker.repos : Array(tracker.repos.prefix(8))

                VStack(spacing: 0) {
                    ForEach(Array(displayed.enumerated()), id: \.element.id) { index, repo in
                        if index > 0 {
                            Divider().padding(.leading, 24)
                        }
                        shipRow(repo)
                    }
                }

                if tracker.repos.count > 8 {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { showAllRepos.toggle() }
                    } label: {
                        Text(showAllRepos ? "Show Less" : "Show All (\(tracker.repos.count))")
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
            // Status dot
            Circle()
                .fill(shipDotColor(repo.shipType))
                .frame(width: 6, height: 6)

            // Name + type
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

    // MARK: - Footer

    private var quitRow: some View {
        HStack {
            Spacer()
            Button("Quit Captain's Log") {
                NSApplication.shared.terminate(nil)
            }
            .font(.system(size: 10))
            .foregroundColor(.secondary.opacity(0.5))
            .buttonStyle(.plain)
            Spacer()
        }
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
