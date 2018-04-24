//
//  ShellProtocol.swift
//  Shell
//
//  Created by devedbox on 2018/4/23.
//

import Foundation

// MARK: - ShellLaunchable.

/// A protocol represents the conforming types can launch a shell of `ShellType`(normally as `Process`)
/// and do any necessary configuration at the point after the conforming type's execution.
public protocol ProcessLaunchable {
    /// Launch the given shell of `ShellType`, and execute the configuration closure at the end of the execution
    /// of the function.
    ///
    /// - Parameter shell: A shell as the given type `ShellType`.
    /// - Parameter config: A closure to do extra configuration of the shell.
    func launch(_ process: Process, config: (Process) -> Void) -> Self
}

// MARK: - ShellOptionsProvider.

/// A protocol represents the conforming types can provide the options for shell to execute such as stdout, stdin,
/// stderr and currentDirectoryPath of the shell process.
public protocol ShellOptionsProvider {
    /// Standard output target type.
    associatedtype StdOut = Pipe
    /// Standard error target type.
    associatedtype StdErr = Pipe
    /// Standard input target type.
    associatedtype StdIn = Pipe
    
    /// Returns the standard output target. Optional.
    var stdout: StdOut? { get }
    /// Returns the standard error target. Optional.
    var stderr: StdErr? { get }
    /// Returns the standard input target. Optional.
    var stdin: StdIn? { get }
    
    /// Returns the current directory path to execute the shell process.
    /// Defaults using `FileManager.default.currentDirectoryPath`.
    var currentDirectoryPath: String { get }
    
    init()
}

// MARK: - Default Implementation.

extension ShellOptionsProvider {
    public var stdout: StdOut? {
        return nil
    }
    public var stderr: StdErr? {
        return nil
    }
    public var stdin: StdIn? {
        return nil
    }
}

extension ShellOptionsProvider {
    public var currentDirectoryPath: String {
        return FileManager.default.currentDirectoryPath
    }
}

// MARK: - ShellResultProtocol.

public protocol ShellResultProtocol: ShellOptionsProvider {
    var exitCode: Int32 { get set }
}

extension ShellResultProtocol where StdOut == Pipe {
    public var output: Data? {
        return stdout?.fileHandleForReading.readDataToEndOfFile()
    }
}

extension ShellResultProtocol where StdErr == Pipe {
    public var error: Data? {
        return stderr?.fileHandleForReading.readDataToEndOfFile()
    }
}

// MARK: - ShellProtocol.

public protocol ShellProtocol: ExpressibleByStringLiteral {
    associatedtype Result: ShellOptionsProvider
    
    func execute() -> Result
}
