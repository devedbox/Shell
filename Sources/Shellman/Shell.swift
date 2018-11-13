// Shell.swift
// Shellman
//
// Created by devedbox.
//

import Foundation

/// Shell associating `DirectResult` to execute command at subprocess and using the default
/// stdout, stdin, stderr of that process.
public typealias ShellOut = Shell<DirectResult>
/// Shell associating `RerirectResult` to execute command at subprocess and using the custom
/// stdout, stdin, stderr to gain outputs of that process.
public typealias ShellIn = Shell<RerirectResult>

// MARK: - CommandLine.

/// A type that parses the command line arguments.
public struct CommandLine {
  /// The count of the arguments excluding the command path.
  public var argc: Int32 {
    return Int32(arguments.underestimatedCount) - 1
  }
  /// The parsed arguments.
  public private(set) var arguments: [String] = []
  /// Parse the given command line string and creates an instance of 'CommandLine'.
  ///
  /// - Parameter commandLine: The command line raw string value.
  public init(_ commandLine: String) {
    var isEscaping: Bool = false
    var isQuoting: Bool = false
    var iterator = commandLine.makeIterator()
    
    while let char = iterator.next() {
      switch char {
      case "\\" where !isEscaping: isEscaping = true
      case "\"" where !isEscaping: fallthrough
      case "'"  where !isEscaping: isQuoting.toggle()
      case " "  where !isEscaping:
        if isQuoting { fallthrough }
        if let last = arguments.last, last.isEmpty {
          break
        }
        
        arguments.append(String())
      default:
        isEscaping ? isEscaping.toggle() : ()
        arguments.isEmpty ? arguments.append(String()) : ()
        arguments.append(arguments.popLast()! + String(char))
      }
    }
    
    if let last = arguments.last, last.isEmpty {
      arguments.removeLast()
    }
  }
}

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
  public init(
    _ commands: String)
  {
    self.init(CommandLine(commands).arguments)
  }
  /// Creates new instance of `Shell`
  internal init(
    _ commandsArgs: [String])
  {
    var commands = commandsArgs
    _process.launchPath = executable(commands.removeFirst())
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
    
    apply(result.stdout) {
      _process.standardOutput = $0
    }
    apply(result.stdin) {
      _process.standardInput = $0
    }
    apply(result.stderr) {
      _process.standardError = $0
    }
    
    _process.launch()
    
    if result.shouldWaitUntilExit {
      _process.waitUntilExit()
      result.exitCode = _process.terminationStatus
    } else {
      _process.terminationHandler = {
        result.exitCode = $0.terminationStatus
      }
    }
    
    return result
  }
}
