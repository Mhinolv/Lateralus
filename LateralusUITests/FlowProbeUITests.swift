import XCTest

/// Walks the core loop — open the daily challenge, answer, save, review in
/// the journal — and attaches a screenshot of each screen.
final class FlowProbeUITests: XCTestCase {

    @MainActor
    func testDailyFlow() throws {
        let app = launchApp()

        let begin = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Begin' OR label CONTAINS 'Answer again'")).firstMatch
        XCTAssertTrue(begin.waitForExistence(timeout: 10))
        begin.tap()

        let editor = app.textViews.firstMatch
        XCTAssertTrue(editor.waitForExistence(timeout: 5))
        snap(app, "01-challenge")

        editor.tap()
        editor.typeText("The keys are a memorial: the old locksmith retired and neighbors hung their spare keys as a thank-you, each one a door he fixed.")

        let save = app.buttons["Save to Journal"]
        XCTAssertTrue(save.waitForExistence(timeout: 5))
        save.tap()
        XCTAssertTrue(app.buttons["Done"].waitForExistence(timeout: 5))
        snap(app, "02-saved")

        app.buttons["Done"].firstMatch.tap()
        XCTAssertTrue(app.buttons["Journal"].waitForExistence(timeout: 5))
        app.buttons["Journal"].tap()
        XCTAssertTrue(app.cells.firstMatch.waitForExistence(timeout: 5))
        snap(app, "03-journal")

        app.cells.firstMatch.tap()
        let savedResponse = app.staticTexts.containing(
            NSPredicate(format: "label CONTAINS 'The keys are a memorial'")
        ).firstMatch
        XCTAssertTrue(savedResponse.waitForExistence(timeout: 5))
        snap(app, "04-detail")

        app.buttons["Insights"].tap()
        XCTAssertTrue(app.staticTexts["Insights"].waitForExistence(timeout: 5))
        snap(app, "05-insights")
    }

    @MainActor
    func testWordGames() throws {
        let app = launchApp()

        // Practice cards live in a LazyVGrid: they don't exist in the
        // accessibility tree until scrolled into view.
        XCTAssertTrue(app.staticTexts["Practice"].waitForExistence(timeout: 10))
        app.swipeUp()
        app.swipeUp()
        let coin = app.buttons.containing(NSPredicate(format: "label CONTAINS 'Coin a Word'")).firstMatch
        XCTAssertTrue(coin.waitForExistence(timeout: 5))
        coin.tap()
        XCTAssertTrue(app.buttons["Close"].waitForExistence(timeout: 5))
        snap(app, "06-coin-a-word")
        app.buttons["Close"].tap()
        XCTAssertTrue(app.staticTexts["Practice"].waitForExistence(timeout: 5))
        app.swipeUp()

        let redefine = app.buttons.containing(NSPredicate(format: "label CONTAINS 'Redefine'")).firstMatch
        XCTAssertTrue(redefine.waitForExistence(timeout: 5))
        if !redefine.isHittable { app.swipeUp() }
        XCTAssertTrue(waitUntilHittable(redefine))
        redefine.tap()
        XCTAssertTrue(app.buttons["Close"].waitForExistence(timeout: 5))
        snap(app, "07-redefine")
    }

    @MainActor
    func testCommonThreadCapturesAWordAndExplanation() throws {
        let app = launchApp()

        XCTAssertTrue(app.staticTexts["Practice"].waitForExistence(timeout: 10))
        app.swipeUp()
        app.swipeUp()
        app.swipeUp()

        let thread = app.buttons.containing(NSPredicate(format: "label CONTAINS 'Common Thread'")).firstMatch
        XCTAssertTrue(thread.waitForExistence(timeout: 5))
        if !thread.isHittable { app.swipeUp() }
        XCTAssertTrue(waitUntilHittable(thread))
        thread.tap()
        snap(app, "08-common-thread")

        let field = app.textFields.firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()
        field.typeText("bridge word")
        // Typing a space must not survive into the field — single word only.
        XCTAssertFalse(field.value as? String == "bridge word")

        let explanation = app.textViews.firstMatch
        XCTAssertTrue(explanation.waitForExistence(timeout: 5))
        explanation.tap()
        explanation.typeText("Both prompts help people cross from one side to another.")
        XCTAssertTrue(app.buttons["Save to Journal"].isEnabled)
        snap(app, "09-common-thread-explanation")
    }

    @MainActor
    func testDiaryEntry() throws {
        let app = launchApp()

        app.buttons["Journal"].tap()
        XCTAssertTrue(app.buttons["New diary entry"].firstMatch.waitForExistence(timeout: 5))
        app.buttons["New diary entry"].firstMatch.tap()
        snap(app, "10-diary")

        let editor = app.textViews.firstMatch
        XCTAssertTrue(editor.waitForExistence(timeout: 5))
        editor.tap()
        editor.typeText("Idea seed: a museum where you can only whisper, and the audio guide whispers back.")
        app.buttons["Save to Journal"].tap()

        // The diary entry lands in the journal list.
        XCTAssertTrue(app.staticTexts["Diary"].firstMatch.waitForExistence(timeout: 5))
        snap(app, "11-journal-with-diary")
    }

    @MainActor
    func testDrawingOnChallenge() throws {
        let app = launchApp()

        let begin = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Begin' OR label CONTAINS 'Answer again'")).firstMatch
        XCTAssertTrue(begin.waitForExistence(timeout: 10))
        begin.tap()

        let addDrawing = app.buttons["Add drawing"]
        XCTAssertTrue(addDrawing.waitForExistence(timeout: 5))
        addDrawing.tap()

        // Scribble a stroke on the canvas.
        let canvas = app.descendants(matching: .any)["Drawing canvas"]
        XCTAssertTrue(canvas.waitForExistence(timeout: 5))
        let start = canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.25, dy: 0.5))
        let end = canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.75, dy: 0.55))
        let secondEnd = canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.45, dy: 0.75))
        start.press(forDuration: 0.15, thenDragTo: end)
        end.press(forDuration: 0.15, thenDragTo: secondEnd)
        snap(app, "12-drawing")

        // Add a caption so the rest of the save flow remains deterministic
        // even when simulator automation treats a PencilKit drag as a scroll.
        app.buttons["Drawing"].firstMatch.tap()
        let editor = app.textViews.firstMatch
        XCTAssertTrue(editor.waitForExistence(timeout: 5))
        editor.tap()
        editor.typeText("Sketch for this idea")

        let save = app.buttons["Save to Journal"]
        XCTAssertTrue(save.waitForExistence(timeout: 5))
        XCTAssertTrue(waitUntilEnabled(save))
        for _ in 0..<5 where !save.isHittable {
            app.swipeUp()
        }
        XCTAssertTrue(waitUntilHittable(save))
        save.tap()
        XCTAssertTrue(app.buttons["Done"].waitForExistence(timeout: 5))
        snap(app, "13-drawing-saved")
    }

    @MainActor
    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing"]
        app.launch()
        return app
    }

    @MainActor
    private func waitUntilHittable(_ element: XCUIElement, timeout: TimeInterval = 5) -> Bool {
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == true AND hittable == true"),
            object: element
        )
        return XCTWaiter.wait(for: [expectation], timeout: timeout) == .completed
    }

    @MainActor
    private func waitUntilEnabled(_ element: XCUIElement, timeout: TimeInterval = 5) -> Bool {
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == true AND enabled == true"),
            object: element
        )
        return XCTWaiter.wait(for: [expectation], timeout: timeout) == .completed
    }

    @MainActor
    private func snap(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
