//
//  Results.swift
//  Shell
//
//  Created by devedbox on 2018/4/24.
//

import Foundation

public struct OutputResult: ShellResultProtocol {
    public typealias StdOut = Pipe
    public typealias StdErr = Pipe
    public typealias StdIn = ()
    
    public var stdout: StdOut? {
        return StdOut()
    }
    public var stderr: StdErr? {
        return StdErr()
    }
    public var stdin: StdIn?
    public var exitCode: Int32 = 0
    
    public init() { }
}

public struct Result: ShellResultProtocol {
    public typealias StdOut = ()
    public typealias StdErr = ()
    public typealias StdIn = ()
    
    public var stdout: StdOut?
    public var stderr: StdErr?
    public var stdin: StdIn?
    
    public var exitCode: Int32 = 0
    
    public init() { }
}
