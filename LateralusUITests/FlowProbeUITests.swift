import XCTest

/// Walks the core loop — open the daily challenge, answer, save, review in
/// the journal — and attaches a screenshot of each screen.
final class FlowProbeUITests: XCTestCase {

    @MainActor
    func testDailyFlow() throws {
        let app = XCUIApplication()
        app.launch()

        let begin = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Begin' OR label CONTAINS 'Answer again'")).firstMatch
        XCTAssertTrue(begin.waitForExistence(timeout: 10))
        begin.tap()

        let editor = app.textViews.firstMatch
        XCTAssertTrue(editor.waitForExistence(timeout: 5))
        sleep(2)
        snap(app, "01-challenge")

        editor.tap()
        editor.typeText("The keys are a memorial: the old locksmith retired and neighbors hung their spare keys as a thank-you, each one a door he fixed.")

        let save = app.buttons["Save to Journal"]
        XCTAssertTrue(save.waitForExistence(timeout: 5))
        save.tap()
        sleep(2)
        snap(app, "02-saved")

        app.buttons["Done"].firstMatch.tap()
        sleep(1)
        app.buttons["Journal"].tap()
        sleep(2)
        snap(app, "03-journal")

        app.cells.firstMatch.tap()
        sleep(2)
        snap(app, "04-detail")

        app.buttons["Insights"].tap()
        sleep(2)
        snap(app, "05-insights")
    }

    @MainActor
    func testWordGames() throws {
        let app = XCUIApplication()
        app.launch()

        // Practice cards live in a LazyVGrid: they don't exist in the
        // accessibility tree until scrolled into view.
        XCTAssertTrue(app.staticTexts["Practice"].waitForExistence(timeout: 10))
        app.swipeUp()
        app.swipeUp()
        sleep(1)
        let coin = app.buttons.containing(NSPredicate(format: "label CONTAINS 'Coin a Word'")).firstMatch
        XCTAssertTrue(coin.waitForExistence(timeout: 5))
        coin.tap()
        sleep(2)
        snap(app, "06-coin-a-word")
        app.buttons["Close"].tap()
        sleep(2)
        app.swipeUp()
        sleep(1)

        let redefine = app.buttons.containing(NSPredicate(format: "label CONTAINS 'Redefine'")).firstMatch
        XCTAssertTrue(redefine.waitForExistence(timeout: 5))
        if !redefine.isHittable { app.swipeUp(); sleep(1) }
        redefine.tap()
        sleep(2)
        snap(app, "07-redefine")
    }

    @MainActor
    func testCommonThreadEnforcesSingleWord() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["Practice"].waitForExistence(timeout: 10))
        app.swipeUp()
        app.swipeUp()
        app.swipeUp()
        sleep(1)

        let thread = app.buttons.containing(NSPredicate(format: "label CONTAINS 'Common Thread'")).firstMatch
        XCTAssertTrue(thread.waitForExistence(timeout: 5))
        if !thread.isHittable { app.swipeUp(); sleep(1) }
        thread.tap()
        sleep(2)
        snap(app, "08-common-thread")

        let field = app.textFields.firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()
        field.typeText("bridge word")
        sleep(1)
        // Typing a space must not survive into the field — single word only.
        XCTAssertFalse(field.value as? String == "bridge word")
        snap(app, "09-common-thread-single-word")
    }

    @MainActor
    func testDiaryEntry() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["Journal"].tap()
        sleep(1)
        app.buttons["New diary entry"].firstMatch.tap()
        sleep(1)
        snap(app, "10-diary")

        let editor = app.textViews.firstMatch
        XCTAssertTrue(editor.waitForExistence(timeout: 5))
        editor.tap()
        editor.typeText("Idea seed: a museum where you can only whisper, and the audio guide whispers back.")
        app.buttons["Save to Journal"].tap()
        sleep(2)

        // The diary entry lands in the journal list.
        XCTAssertTrue(app.staticTexts["Diary"].firstMatch.waitForExistence(timeout: 5))
        snap(app, "11-journal-with-diary")
    }

    @MainActor
    func testDrawingOnChallenge() throws {
        let app = XCUIApplication()
        app.launch()

        let begin = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Begin' OR label CONTAINS 'Answer again'")).firstMatch
        XCTAssertTrue(begin.waitForExistence(timeout: 10))
        begin.tap()
        sleep(1)

        let addDrawing = app.buttons["Add drawing"]
        XCTAssertTrue(addDrawing.waitForExistence(timeout: 5))
        addDrawing.tap()
        sleep(2)

        // Scribble a stroke on the canvas.
        let canvas = app.otherElements.matching(NSPredicate(format: "elementType == 47")).firstMatch
        let window = app.windows.firstMatch
        let start = window.coordinate(withNormalizedOffset: CGVector(dx: 0.3, dy: 0.55))
        let end = window.coordinate(withNormalizedOffset: CGVector(dx: 0.7, dy: 0.6))
        start.press(forDuration: 0.05, thenDragTo: end)
        _ = canvas // canvas located via coordinates; kept for documentation
        sleep(1)
        snap(app, "12-drawing")

        app.swipeUp()
        let save = app.buttons["Save to Journal"]
        XCTAssertTrue(save.waitForExistence(timeout: 5))
        if save.isHittable && save.isEnabled {
            save.tap()
            sleep(2)
            snap(app, "13-drawing-saved")
        }
    }

    @MainActor
    private func snap(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
