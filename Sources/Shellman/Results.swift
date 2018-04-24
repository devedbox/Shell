//
//  Results.swift
//  Shell
//
//  Created by devedbox on 2018/4/24.
//

import Foundation

// MARK: - OutputResult.

public struct OutputResult: ShellResultProtocol {
    /// Standard output target type.
    public typealias StdOut = Pipe
    /// Standard error target type.
    public typealias StdErr = Pipe
    /// Returns the standard output target.
    public var stdout: StdOut? { return StdOut() }
    /// Returns the standard error target.
    public var stderr: StdErr? { return StdErr() }
    /// The exit code of the `Result`.
    public var exitCode: Int32 = 0
    
    public init() { }
}

// MARK: - Result.

public struct Result: ShellResultProtocol {
    /// The exit code of the `Result`.
    public var exitCode: Int32 = 0
    
    public init() { }
}
