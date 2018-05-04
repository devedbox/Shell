// Shell.swift
// Shellman
//
// Created by devedbox.
//

import Foundation

/// Shell associating `Result` to execute command at subprocess and using the default
/// stdout, stdin, stderr of that process.
public typealias ShellOut = Shell<Result>
/// Shell associating `OutputResult` to execute command at subprocess and using the custom
/// stdout, stdin, stderr to gain outputs of that process.
public typealias ShellIn = Shell<OutputResult>

// MARK: - Shell.

/// A type represents the command line process on shell. Using this type instead of process directly to
/// execute commands with specific `ShellResultProtocol`.
public struct Shell<Result: ShellResultProtocol> {
    /// The underlying process instance of the `Shell`.
    private let _process = Process()
    /// Creates an instance of `Shell` with the commands string literal. Using white space to separate
    /// diffrent part of the commands like this:
    /// ```
    /// {command} {arg0} {arg1} ...{argn}
    /// ```
    ///
    /// - Parameter commands: Command string along with arguments of the command.
    /// - Returns: Instance of `Shell` with the given command and args.
    public init(_ commands: String) {
        self.init(commands.split(separator: " ").map { String($0) })
    }
    /// Creates new instance of `Shell`
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

// MARK: -

extension Shell {
    public static func shells(_ multilines: String) -> [Shell<Result>] {
        return (multilines as NSString).components(separatedBy: .newlines).map { Shell<Result>($0) }
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
