//
//  ALTENLoggerCommon.swift
//
//  Copyright © 2022 ALTEN. All rights reserved.
//

import Foundation
import Logging

public struct StdioOutputStream: TextOutputStream {
    #if canImport(WASILibc)
    internal let file: OpaquePointer
    #else
    internal let file: UnsafeMutablePointer<FILE>
    #endif
    internal let flushMode: FlushMode

    public func write(_ string: String) {
        string.withCString { ptr in
            #if os(Windows)
            _lock_file(self.file)
            #elseif canImport(WASILibc)
            // no file locking on WASI
            #else
            flockfile(self.file)
            #endif
            defer {
                #if os(Windows)
                _unlock_file(self.file)
                #elseif canImport(WASILibc)
                // no file locking on WASI
                #else
                funlockfile(self.file)
                #endif
            }
            _ = fputs(ptr, self.file)
            if case .always = self.flushMode {
                self.flush()
            }
        }
    }

    /// Flush the underlying stream.
    /// This has no effect when using the `.always` flush mode, which is the default
    internal func flush() {
        _ = fflush(self.file)
    }

    public static let stderr = StdioOutputStream(file: Darwin.stderr, flushMode: .always)
    public static let stdout = StdioOutputStream(file: Darwin.stdout, flushMode: .always)

    /// Defines the flushing strategy for the underlying stream.
    internal enum FlushMode {
        case undefined
        case always
    }
}

public extension Logger.Level {
    var color: String {
        switch self {
        case .trace:
            return "⬜️"
        case .debug:
            return "🟩"
        case .info:
            return "🟦"
        case .notice:
            return "🟫"
        case .warning:
            return "🟨"
        case .error:
            return "🟥"
        case .critical:
            return "🟪"
        }
    }
}
