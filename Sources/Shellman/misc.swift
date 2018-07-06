//
//  misc.swift
//  Shell
//
//  Created by devedbox on 2018/4/24.
//
#if os(Linux)
import Glibc
#else
import Darwin
#endif
import Foundation

/// Returns the environment variable path of the system if any.
internal var _envPaths: [String] = { () -> [String] in
    let env_paths = getenv("PATH")
    let char_env_paths = unsafeBitCast(env_paths, to: UnsafePointer<CChar>.self)
    #if swift(>=4.1)
    return
        String(validatingUTF8: char_env_paths)?
            .split(separator: ":")
            .compactMap({ String($0) })
            ?? []
    #else
    return
    String(validatingUTF8: char_env_paths)?
    .split(separator: ":")
    .flatMap({ String($0) })
    ?? []
    #endif
}()
/// Find the executable path with a path extension.
internal func executable(_ name: String) -> String? {
    let paths =
        [FileManager.default.currentDirectoryPath] + _envPaths
    return
        paths.map({
            name.hasPrefix("/")
                ? $0 + name
                : $0 + "/\(name)"
        }).first(where: {
            FileManager.default.isExecutableFile(atPath: $0)
        })
}

/// Apply the given closure to the given wrapped value when the wrapped value is
/// not nil and return the closure's executed result.
internal func apply<T, U>(_ wrapped: U?, with whenNotNil: (U) -> T) -> T? {
    if let unwrapped = wrapped {
        return whenNotNil(unwrapped)
    }
    
    return nil
}

/// Creates a out stream shell with the given commands.
public func shellsOut(_ commands: String) {
    ShellOut.shells(commands).forEach { $0.execute() }
}
