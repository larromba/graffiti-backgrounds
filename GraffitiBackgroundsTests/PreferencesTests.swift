@testable import Graffiti_Backgrounds
import Reachability
import TestExtensions
import XCTest

final class PreferencesTests: XCTestCase {
    func testPreferencesOnMenuClickOpensPreferences() {
        // mocks
        let windowController = MockWindowController()
        let env = AppTestEnvironment(preferencesWindowController: windowController)
        env.inject()

        // sut
        env.statusItem.menu?.click(at: AppMenu.Order.preferences.rawValue)

        // test
        XCTAssertTrue(windowController.invocations.isInvoked(MockWindowController.showWindow1.name))
    }

    func testPreferencesOnMenuClickIsBoughtToFront() {
        // mocks
        let application = MockApplication()
        let env = AppTestEnvironment(application: application)
        env.inject()

        // sut
        env.statusItem.menu?.click(at: AppMenu.Order.preferences.rawValue)

        // test
        XCTAssertTrue(application.invocations.isInvoked(MockApplication.activate1.name))
    }

    func testPreferencesRenderOnOpening() {
        // mocks
        let preferences = Preferences(isAutoRefreshEnabled: true, autoRefreshTimeIntervalHours: 1, numberOfPhotos: 2)
        let userDefaults = MockUserDefaults(preferences: preferences)
        let preferencesUI = makePreferencesUI()
        let env = AppTestEnvironment(preferencesWindowController: preferencesUI.0, userDefaults: userDefaults)
        env.inject()

        // sut
        env.statusItem.menu?.click(at: AppMenu.Order.preferences.rawValue)

        // test
        XCTAssertEqual(preferencesUI.1.autoRefreshCheckBox.state, .on)
        XCTAssertEqual(preferencesUI.1.autoRefreshIntervalTextField.stringValue, "1")
        XCTAssertEqual(preferencesUI.1.numberOfPhotosTextField.stringValue, "2")
    }

    func testPreferencesPersistOnEveryChange() {
        // mocks
        let userDefaults = MockUserDefaults()
        let preferencesUI = makePreferencesUI()
        let env = AppTestEnvironment(preferencesWindowController: preferencesUI.0, userDefaults: userDefaults)
        env.inject()

        // sut
        env.statusItem.menu?.click(at: AppMenu.Order.preferences.rawValue)
        preferencesUI.1.autoRefreshCheckBox.performClick(nil)
        preferencesUI.1.autoRefreshCheckBox.performClick(nil)
        preferencesUI.1.autoRefreshIntervalTextField.stringValue = "10"
        preferencesUI.1.autoRefreshIntervalTextField.fireTextChagedEvent(in: preferencesUI.1)
        preferencesUI.1.numberOfPhotosTextField.stringValue = "5"
        preferencesUI.1.numberOfPhotosTextField.fireTextChagedEvent(in: preferencesUI.1)

        // test
        XCTAssertEqual(userDefaults.preferences(at: 0)?.isAutoRefreshEnabled, false)
        XCTAssertEqual(userDefaults.preferences(at: 1)?.isAutoRefreshEnabled, true)
        XCTAssertEqual(userDefaults.preferences(at: 2)?.autoRefreshTimeIntervalHours, 10)
        XCTAssertEqual(userDefaults.preferences(at: 3)?.numberOfPhotos, 5)
    }

    func testPreferencesRestartDownloadTimerIfChanged() {
        // mocks
        let preferencesUI = makePreferencesUI()
        let env = AppTestEnvironment(preferencesWindowController: preferencesUI.0)
        env.inject()
        let photoDelegate = MockPhotoManagerDelegate()
        env.photoManager.setDelegate(photoDelegate)
        let preferences = Preferences(isAutoRefreshEnabled: true, autoRefreshTimeIntervalHours: 1, numberOfPhotos: 0)
        env.photoManager.setPreferences(preferences)

        // sut
        env.statusItem.menu?.click(at: AppMenu.Order.preferences.rawValue)
        preferencesUI.1.autoRefreshIntervalTextField.stringValue = "0"
        preferencesUI.1.autoRefreshIntervalTextField.fireTextChagedEvent(in: preferencesUI.1)

        // test
        waitSync()
        XCTAssertTrue(photoDelegate.invocations
            .isInvoked(MockPhotoManagerDelegate.photoManagerTimerTriggered1.name))
    }

    // MARK: - private

    private func makePreferencesUI() -> (NSWindowController, PreferencesViewController) {
        guard
            let windowController = NSStoryboard.preferences.instantiateInitialController() as? NSWindowController,
            let preferencesViewController = windowController.contentViewController as? PreferencesViewController else {
                fatalError("expected NSWindowController & PreferencesViewController")
        }
        return (windowController, preferencesViewController)
    }
}

// MARK: - MockUserDefaults

private extension MockUserDefaults {
    convenience init(preferences: Preferences) {
        self.init()
        let data = (try? JSONEncoder().encode(preferences)) ?? Data()
        actions.set(returnValue: data, for: MockUserDefaults.object1.name)
    }

    func preferences(at index: Int) -> Preferences? {
        guard let data = invocations
            .find(MockUserDefaults.set2.name)[safe: index]?
            .parameter(for: MockUserDefaults.set2.params.value) as? Data else {
                return nil
        }
        return try? JSONDecoder().decode(Preferences.self, from: data)
    }
}
