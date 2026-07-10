import XCTest

final class LateralusUITests: XCTestCase {
    @MainActor
    func testLaunchShowsToday() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.staticTexts["Think sideways."].waitForExistence(timeout: 10))
    }
}
