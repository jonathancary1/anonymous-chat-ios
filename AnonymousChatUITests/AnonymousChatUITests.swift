import XCTest

class AnonymousChatUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    func testStartChattingButton() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.buttons["Start Chatting"].waitForExistence(timeout: 8.0))
        app.buttons["Start Chatting"].tap()
        XCTAssertTrue(app.staticTexts["Loading..."].waitForExistence(timeout: 8.0))
        XCTAssertTrue(app.staticTexts["Waiting for someone..."].waitForExistence(timeout: 8.0))
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
}
