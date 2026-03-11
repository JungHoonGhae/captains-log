import XCTest
@testable import CaptainsLog

final class GamificationTests: XCTestCase {

    // MARK: - Water Level
    // Sleep is disabled in all water level tests to get deterministic time-based results.

    func testWaterLevel_noActivity_returns100() {
        let tracker = GitTracker()
        tracker.sleepEnabled = false
        let level = tracker.calculateWaterLevel(lastActivity: nil)
        XCTAssertEqual(level, 100)
    }

    func testWaterLevel_justCommitted_nearZero() {
        let tracker = GitTracker()
        tracker.sleepEnabled = false
        let level = tracker.calculateWaterLevel(lastActivity: Date())
        XCTAssertLessThan(level, 1.0)
    }

    func testWaterLevel_oneHourInactive_equals20() {
        let tracker = GitTracker()
        tracker.sleepEnabled = false
        let oneHourAgo = Date().addingTimeInterval(-3600)
        let level = tracker.calculateWaterLevel(lastActivity: oneHourAgo)
        XCTAssertEqual(level, 20.0, accuracy: 0.5)
    }

    func testWaterLevel_8HoursInactive_equals100() {
        let tracker = GitTracker()
        tracker.sleepEnabled = false
        let eightHoursAgo = Date().addingTimeInterval(-8 * 3600)
        let level = tracker.calculateWaterLevel(lastActivity: eightHoursAgo)
        XCTAssertEqual(level, 100.0, accuracy: 0.1)
    }

    // MARK: - PirateRank

    func testRank_captain_waterLevelUnder20() {
        let tracker = GitTracker()
        tracker.waterLevel = 10
        XCTAssertEqual(tracker.rank, .captain)
    }

    func testRank_firstMate_waterLevel30() {
        let tracker = GitTracker()
        tracker.waterLevel = 30
        XCTAssertEqual(tracker.rank, .firstMate)
    }

    func testRank_deckhand_waterLevel50() {
        let tracker = GitTracker()
        tracker.waterLevel = 50
        XCTAssertEqual(tracker.rank, .deckhand)
    }

    func testRank_castaway_waterLevel70() {
        let tracker = GitTracker()
        tracker.waterLevel = 70
        XCTAssertEqual(tracker.rank, .castaway)
    }

    func testRank_davyJones_waterLevelOver80() {
        let tracker = GitTracker()
        tracker.waterLevel = 90
        XCTAssertEqual(tracker.rank, .davyJones)
    }

    // MARK: - ShipType

    func testShipType_flagship_5CommitsToday() {
        var repo = RepoInfo(path: "/fake/repo", flagshipGoal: 5)
        repo.lastCommit = Date().addingTimeInterval(-3600)
        repo.todayCommits = 5
        XCTAssertEqual(repo.shipType, .flagship)
    }

    func testShipType_warship_committedWithin24Hours() {
        var repo = RepoInfo(path: "/fake/repo")
        repo.lastCommit = Date().addingTimeInterval(-10 * 3600)
        repo.todayCommits = 1
        XCTAssertEqual(repo.shipType, .warship)
    }

    func testShipType_galleon_committed2DaysAgo() {
        var repo = RepoInfo(path: "/fake/repo")
        repo.lastCommit = Date().addingTimeInterval(-48 * 3600)
        repo.todayCommits = 0
        XCTAssertEqual(repo.shipType, .galleon)
    }

    func testShipType_sloop_committed5DaysAgo() {
        var repo = RepoInfo(path: "/fake/repo")
        repo.lastCommit = Date().addingTimeInterval(-5 * 24 * 3600)
        repo.todayCommits = 0
        XCTAssertEqual(repo.shipType, .sloop)
    }

    func testShipType_dinghy_committed15DaysAgo() {
        var repo = RepoInfo(path: "/fake/repo")
        repo.lastCommit = Date().addingTimeInterval(-15 * 24 * 3600)
        repo.todayCommits = 0
        XCTAssertEqual(repo.shipType, .dinghy)
    }

    func testShipType_shipwreck_noCommit() {
        let repo = RepoInfo(path: "/fake/repo")
        XCTAssertEqual(repo.shipType, .shipwreck)
    }

    func testShipType_shipwreck_over30DaysAgo() {
        var repo = RepoInfo(path: "/fake/repo")
        repo.lastCommit = Date().addingTimeInterval(-31 * 24 * 3600)
        repo.todayCommits = 0
        XCTAssertEqual(repo.shipType, .shipwreck)
    }

    // MARK: - RepoConfig JSON roundtrip

    func testRepoConfig_roundtrip() throws {
        let config = RepoConfig(
            repos: ["/path/to/repo"],
            githubEnabled: true,
            hasScannedOnce: true,
            language: "en",
            sleepEnabled: false,
            sleepStart: 23,
            sleepEnd: 7,
            sleepDays: [2, 3, 4, 5, 6],
            shipViewStyle: "classic",
            navigatorEnabled: true,
            captainName: "Blackbeard",
            cardOrder: ["navigator", "fleet", "ships", "coffee"],
            showWeather: true,
            showChart: false,
            showVoyage: true,
            showTreasure: nil,
            showSpeechBubble: true,
            dailyGoal: 5
        )

        let data = try JSONEncoder().encode(config)
        let decoded = try JSONDecoder().decode(RepoConfig.self, from: data)

        XCTAssertEqual(decoded.repos, config.repos)
        XCTAssertEqual(decoded.captainName, config.captainName)
        XCTAssertEqual(decoded.dailyGoal, config.dailyGoal)
        XCTAssertEqual(decoded.githubEnabled, config.githubEnabled)
        XCTAssertEqual(decoded.language, config.language)
        XCTAssertEqual(decoded.sleepStart, config.sleepStart)
        XCTAssertEqual(decoded.sleepEnd, config.sleepEnd)
    }

    func testRepoConfig_minimalInit_roundtrip() throws {
        let config = RepoConfig(repos: ["/my/repo"])
        let data = try JSONEncoder().encode(config)
        let decoded = try JSONDecoder().decode(RepoConfig.self, from: data)

        XCTAssertEqual(decoded.repos, ["/my/repo"])
        XCTAssertNil(decoded.captainName)
        XCTAssertNil(decoded.githubEnabled)
    }

    // MARK: - RepoInfo defaults

    func testRepoInfo_defaultValues() {
        let repo = RepoInfo(path: "/my/repo")
        XCTAssertEqual(repo.todayCommits, 0)
        XCTAssertEqual(repo.dirtyFiles, 0)
        XCTAssertEqual(repo.unpushedCommits, 0)
        XCTAssertEqual(repo.flagshipGoal, 5)
        XCTAssertNil(repo.lastCommit)
        XCTAssertEqual(repo.id, "/my/repo")
        XCTAssertEqual(repo.name, "repo")
    }

    func testRepoInfo_nameExtractsLastComponent() {
        let repo = RepoInfo(path: "/Users/captain/Projects/my-cool-app")
        XCTAssertEqual(repo.name, "my-cool-app")
    }
}
