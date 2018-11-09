import XCTest
@testable import Shellman

final class ShellTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        let result = ("ls -al" as ShellIn).execute()
        print(result.output as Any)
        print(result.exitCode)
        
        Shellman.shellsOut("""
        git clone https://github.com/devedbox/Commander.git
        cd ./Commander
        swift build -c release
        cd ../
        rm -rf ./Commander
        """)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
