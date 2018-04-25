//
//  ShellProtocol.swift
//  Shellman
//
//  Created by devedbox on 2018/4/23.
//

import Foundation

// MARK: - ShellOptionsProvider.

/// A protocol represents the conforming types can provide the options for shell to execute such as stdout, stdin
/// , stderr and currentDirectoryPath of the shell process.
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
// MARK: Standards.

extension ShellOptionsProvider {
    /// Returns the standard output target. Defaults to be nil.
    public var stdout: StdOut? { return nil }
    /// Returns the standard error target. Defaults to be nil.
    public var stderr: StdErr? { return nil }
    /// Returns the standard input target. Defaults to be nil/
    public var stdin: StdIn? { return nil }
}

// MARK: CurrentDirectoryPath.

extension ShellOptionsProvider {
    /// Returns the current directory path to execute the shell process.
    /// Defaults using `FileManager.default.currentDirectoryPath`.
    public var currentDirectoryPath: String {
        return FileManager.default.currentDirectoryPath
    }
}

// MARK: - ShellResultProtocol.

/// A protocol represents the executing result of `Shell`. Any instance of `Shell` must specify a
/// result type conforming to `ShellResultProtocol`.
public protocol ShellResultProtocol: ShellOptionsProvider {
    /// The exit code of the shell process.
    var exitCode: Int32 { get set }
}

// MARK: - Default Implementation.

extension ShellResultProtocol where StdOut == Pipe {
    /// Read output data from the stdout.
    public var output: Data? {
        return stdout?.fileHandleForReading.readDataToEndOfFile()
    }
}

extension ShellResultProtocol where StdErr == Pipe {
    /// Read error data from the stderr.
    public var error: Data? {
        return stderr?.fileHandleForReading.readDataToEndOfFile()
    }
}
