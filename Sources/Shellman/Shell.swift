// Shell.swift
// Shellman
//
// Created by devedbox.
//

import Foundation

// MARK: - Shell.

/// A type represents the command line process on shell. Using this type instead of process directly to
/// execute commands with specific `ShellResultProtocol`.
public struct Shell<Result: ShellResultProtocol>: ShellProtocol {
    public typealias StringLiteralType = String
    
    private let _process = Process()
    
    public init(_ commands: String) {
        self.init(stringLiteral: commands)
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
    public func execute(at path: String? = nil) -> Result {
        var result = Result()
        
        _process.currentDirectoryPath = path ?? result.currentDirectoryPath
        result.stdout != nil ? _process.standardOutput = result.stdout : ()
        result.stderr != nil ? _process.standardError = result.stderr : ()
        result.stdin != nil ? _process.standardInput = result.stdin : ()
        
        _process.launch()
        _process.waitUntilExit()
        
        result.exitCode = _process.terminationStatus
        return result
    }
}

public typealias ShellOut = Shell<Result>
public typealias ShellIn = Shell<OutputResult>
