//
//  Results.swift
//  Shell
//
//  Created by devedbox on 2018/4/24.
//

import Foundation

// MARK: - OutputResult.

public final class OutputResult: ShellResultProtocol {
    /// Standard output target type.
    public typealias StdOut = Pipe
    /// Standard error target type.
    public typealias StdErr = Pipe
    /// Returns the standard output target.
    public var stdout: StdOut? = StdOut()
    /// Returns the standard error target.
    public var stderr: StdErr? = StdOut()
    /// The exit code of the `Result`.
    public var exitCode: Int32 = 0
    /// Should block the process and wait until exit. Default is false.
    public var shouldWaitUntilExit: Bool = false
    
    public init() { }
}

// MARK: - Result.

public struct Result: ShellResultProtocol {
    /// The exit code of the `Result`.
    public var exitCode: Int32 = 0
    
    public init() { }
}
