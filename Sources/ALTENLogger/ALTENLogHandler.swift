//
//  ALTENLogHandler.swift
//  Rafita_app
//
//  Created by Rafael FERNANDEZ on 31/1/22.
//  Copyright © 2022 company_app. All rights reserved.
//

import Foundation
import Logging
import Darwin
import ALTENLoggerCore

/// Logger que devuelve la salida por consola
public struct ALTENLogHandler: LogHandler {
    /// Factory that makes a `ALTENLogHandler` to directs its output to `stdout`
    public static func standardOutput(label: String) -> ALTENLogHandler {
        return ALTENLogHandler(label: label, stream: StdioOutputStream.stdout)
    }

    /// Factory that makes a `ALTENLogHandler` to directs its output to `stderr`
    public static func standardError(label: String) -> ALTENLogHandler {
        return ALTENLogHandler(label: label, stream: StdioOutputStream.stderr)
    }

    private let stream: TextOutputStream
    private let label: String
    
    /// Nivel de log a partir del cual mostrará la información
    public var logLevel: Logger.Level = .info

    private var prettyMetadata: String?
    
    /// Metadatos globales del log que se incluirán en cada llamada al log
    public var metadata = Logger.Metadata() {
        didSet {
            self.prettyMetadata = self.prettify(self.metadata)
        }
    }

    public subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
        get {
            return self.metadata[metadataKey]
        }
        set {
            self.metadata[metadataKey] = newValue
        }
    }

    // internal for testing only
    internal init(label: String, stream: TextOutputStream) {
        self.label = label
        self.stream = stream
    }

    public func log(level: Logger.Level,
                    message: Logger.Message,
                    metadata: Logger.Metadata?,
                    source: String,
                    file: String,
                    function: String,
                    line: UInt) {
        let prettyMetadata = metadata?.isEmpty ?? true
            ? self.prettyMetadata
            : self.prettify(self.metadata.merging(metadata!, uniquingKeysWith: { _, new in new }))

        var stream = self.stream
        let result = "\(self.timestamp()) [\(level.rawValue.uppercased()) \(self.label)] [\(file.split(separator: "/").last ?? "\(file)") ➝ \(function) ➝ L:\(line)] : \(message)\(prettyMetadata.map { " - [\($0)]" } ?? "")"
        stream.write("\(level.color) \(result)\n")
    }

    private func prettify(_ metadata: Logger.Metadata) -> String? {
        return !metadata.isEmpty
            ? metadata.lazy.sorted(by: { $0.key < $1.key }).map { "\($0): \"\($1)\"" }.joined(separator: " ")
            : nil
    }

    private func timestamp() -> String {
        var buffer = [Int8](repeating: 0, count: 255)
        var timestamp = time(nil)
        let localTime = localtime(&timestamp)
        strftime(&buffer, buffer.count, "%Y-%m-%dT%H:%M:%S%z", localTime)
        return buffer.withUnsafeBufferPointer {
            $0.withMemoryRebound(to: CChar.self) {
                String(cString: $0.baseAddress!)
            }
        }
    }
}

