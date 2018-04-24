// Shell.swift
// Shellman
//
// Created by devedbox.
//

import Foundation

public typealias ShellOut = Shell<Result>
public typealias ShellIn = Shell<OutputResult>

// MARK: - Shell.

/// A type represents the command line process on shell. Using this type instead of process directly to
/// execute commands with specific `ShellResultProtocol`.
public struct Shell<Result: ShellResultProtocol> {
    /// The underlying process instance of the `Shell`.
    private let _process = Process()
    
    public init(_ commands: String) {
        self.init(commands.split(separator: " ").map { String($0) })
    }
    
    internal init(_ commandsArgs: [String]) {
        var commands = commandsArgs
        _process.launchPath = _executable(commands.removeFirst())
        _process.arguments = commands
    }
}

// MARK: - ExpressibleByStringLiteral.

extension Shell: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    
    public init(stringLiteral commands: String) {
        self.init(commands)
    }
}

// MARK: - Public.

extension Shell {
    public var command: String? {
        guard let cmd = _process.launchPath?.split(separator: "/").last else {
            return nil
        }
        return String(cmd)
    }
    
    public var arguments: [String] {
        return _process.arguments ?? []
    }
    
    @discardableResult
    public func execute(at path: String? = nil) -> Result {
        var result = Result()
        
        _process.currentDirectoryPath = path ?? result.currentDirectoryPath
        if result.stdout != nil {
            _process.standardOutput = result.stdout
        }
        if result.stderr != nil {
            _process.standardError = result.stderr
        }
        if result.stdin != nil {
            _process.standardInput = result.stdin
        }
        
        _process.launch()
        _process.waitUntilExit()
        
        result.exitCode = _process.terminationStatus
        return result
    }
}
