import XCTest

final class IPadLoginUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLoginFlowOnIPad() throws {
        let app = XCUIApplication()
        app.launchArguments.append("--uitesting-ipad")
        app.launch()

        let window = app.windows.element(boundBy: 0)
        XCTAssertGreaterThanOrEqual(window.frame.size.width, 768, "Expected iPad width")

        let emailField = app.textFields["Имэйл"]
        XCTAssertTrue(emailField.waitForExistence(timeout: 5))
        emailField.tap()
        emailField.typeText("user@example.com")

        let passwordField = app.secureTextFields["Нууц үг"]
        XCTAssertTrue(passwordField.waitForExistence(timeout: 5))
        passwordField.tap()
        passwordField.typeText("password123")

        let loginButton = app.buttons["Нэвтрэх"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5))
        loginButton.tap()

        let progressIndicator = app.activityIndicators.firstMatch
        XCTAssertTrue(progressIndicator.waitForExistence(timeout: 5))
    }
}
