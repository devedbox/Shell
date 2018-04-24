// Shell.swift
// Shell
//
// Created by devedbox.
//

import Foundation

// MARK: - Shell.

/// A type represents the command line process on shell. Using this type instead of process directly to
/// execute commands with specific `ShellResultProtocol`.
public struct Shell<R: ShellResultProtocol>: ShellProtocol {
    public typealias StringLiteralType = String
    public typealias Result = R
    
    private let _process = Process()
    
    public var command: String? {
        guard let cmd = _process.launchPath?.split(separator: "/").last else {
            return nil
        }
        
        return String(cmd)
    }
    
    public init(stringLiteral command: String) {
        self.init(command.split(separator: " ").map { String($0) })
    }
    
    internal init(_ commandsArgs: [String]) {
        var commands = commandsArgs
        _process.launchPath = _executable(commands.removeFirst())
        _process.arguments = commands
    }
    
    @discardableResult
    public func execute() -> Result {
        return {
            var result = Result()
            _process.standardOutput = result.stdout
            _process.standardError = result.stderr
            _process.standardInput = result.stdin
            _process.currentDirectoryPath = result.currentDirectoryPath
            
            _process.launch()
            _process.waitUntilExit()
            
            result.exitCode = _process.terminationStatus
            return result
        }()
    }
}
