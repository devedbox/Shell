import XCTest
@testable import Shell

final class ShellTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        print(("ls -al" as Shell<OutputResult>).execute().output as Any)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
