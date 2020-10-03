import XCTest
@testable import jsonmodel

final class jsonmodelTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(jsonmodel().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
