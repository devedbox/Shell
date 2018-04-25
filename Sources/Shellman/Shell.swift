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
    /// Creates new instance of `Shell` with the given command along with arguments as a `Array`.
    ///
    /// - Parameter commandsArgs: The array of command and arguments.
    /// - Returns: Instance of `Shell` with the given command and args.
    internal init(_ commandsArgs: [String]) {
        var commands = commandsArgs
        _process.launchPath = _executable(commands.removeFirst())
        _process.arguments = commands
    }
}

// MARK: - ExpressibleByStringLiteral.

extension Shell: ExpressibleByStringLiteral {
    /// StringLiteralType alias of `String`.
    public typealias StringLiteralType = String
    /// Creates an instance of `Shell` with the commands string literal. Using white space to separate
    /// diffrent part of the commands like this:
    /// ```
    /// {command} {arg0} {arg1} ...{argn}
    /// ```
    ///
    /// - Parameter commands: Command string along with arguments of the command.
    /// - Returns: Instance of `Shell` with the given command and args.
    public init(stringLiteral commands: String) {
        self.init(commands)
    }
}

// MARK: -

/// Easily creates `Shell<R>` from a sting.
///
/// - Parameter commands: A shell commands string.
/// - Parameter as: Generic context.
/// - Returns: An instance of `Shell<R>` from the given shell commands string.
public func shell<R>(_ commands: String, as: Shell<R>.Type) -> Shell<R> {
    return Shell<R>(commands)
}
/// Easily creates `[Shell<R>]` from a multiline sting.
///
/// - Parameter multilines: A multiline shell commands string.
/// - Parameter as: Generic context.
/// - Returns: An instance of `[Shell<R>]` from the given shell commands string.
public func shells<R>(_ multilines: String, as: Shell<R>.Type) -> [Shell<R>] {
    return Shell<R>.shells(from: multilines)
}

extension Shell {
    /// Creates an instance of `[Shell<Result>]` from a multiline string. Shell in the string is separated by `\n`.
    /// ```
    /// """
    /// git clone https://github.com/apple/swift
    /// cd ./swift
    /// swift build -c release
    /// cd ../
    /// rm -rf ./swift
    /// """
    /// ```
    /// - Parameter multilines: The multiline string contains shell commands.
    /// - Returns: An instance of `[Shell<Result>]` represents the shells separated by `\n`.
    public static func shells(from multilines: String) -> [Shell<Result>] {
        return (multilines as NSString).components(separatedBy: .newlines).map { Shell<Result>($0) }
    }
}

// MARK: - Public.

extension Shell {
    /// Returns the executable command of the shell.
    public var command: String? {
        guard let cmd = _process.launchPath?.split(separator: "/").last else {
            return nil
        }
        return String(cmd)
    }
    /// Returns the arguments of command in the shell.
    public var arguments: [String] {
        return _process.arguments ?? []
    }
    /// Launch the command at a given working path as current directory path.
    ///
    /// - Parameter path: Current directory path as working path of the command.
    /// - Returns: An instance of `Result` represents the result of the shell's executing.
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
