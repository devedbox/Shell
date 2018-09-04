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
        git clone https://github.com/apple/swift
        cd ./swift
        swift build -c release
        cd ../
        rm -rf ./swift
        """)
    }
    
    func testScanner() {
        let commands = """
         git commit -m "feat: Updates HAHAHA."
         """
        let shell = ShellOut(commands)
        XCTAssertEqual(
            Set(["commit", "-m", "\"feat: Updates HAHAHA.\""]),
            Set(shell.arguments)
        )
        
        XCTAssertEqual(
            Set(["commit", "-m", "\"haha\""]),
            Set(ShellOut("git commit -m \"haha\"").arguments)
        )
        
        XCTAssertEqual(
            Set(["commit", "-m", "\"haha\"", "\""]),
            Set(ShellOut("git commit -m\"haha\"\"").arguments)
        )
        
        XCTAssertEqual(
            Set(["commit", "-m", "\"haha\"", "\"\""]),
            Set(ShellOut("git commit -m\"haha\"\"\"").arguments)
        )
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
