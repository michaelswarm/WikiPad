//
//  OSLogExtensions.swift
//  TextLibraryProto
//
//  Created by Michael Swarm on 7/13/20.
//
/*
 Document use of OSLog and MyLogger outside source.
 Use of logs generally. Need ability to turn logs on and off per module. Frame with constant log flag to turn logs on and off. Flag can be local var verbose, nested struct Constant.verbose, or fileprivate Constant.verbose.
 
 */

import Foundation
import os.log
import os.signpost

private extension OSLog {
    private static let subsystem = Bundle.main.bundleIdentifier!
    // Log categories are capitalized: SwiftUI, etc.
    static let app = OSLog(subsystem: subsystem, category: "App") // App
    static let model = OSLog(subsystem: subsystem, category: "Model")
    static let view = OSLog(subsystem: subsystem, category: "View") // App

    // static let texts = OSLog(subsystem: subsystem, category: "texts") // Library texts (database)
    static let store = OSLog(subsystem: subsystem, category: "Store") // Store Protocol Implementations: Core Data Store.
    static let document = OSLog(subsystem: subsystem, category: "Document") // Text Document Model
    static let library = OSLog(subsystem: subsystem, category: "Library") // Library Model
    static let text = OSLog(subsystem: subsystem, category: "Text") // Text Model
    static let edit = OSLog(subsystem: subsystem, category: "Edit") // Text Editor
    static let textedit = OSLog(subsystem: subsystem, category: "TextEdit") // Text Editor
    static let cloud = OSLog(subsystem: subsystem, category: "Cloud") // Cloud Stack
    static let sync = OSLog(subsystem: subsystem, category: "Sync") // Cloud Sync
    
    // If category for type (store, document, library), then no need for class name? Or even function name? (Common to search code for message string.) Avoid computing strings for logs that are never used. Put message right into log call?
}

public struct MyLogger {
    // Attempt at simple version of new Logger API from IOS 14+ and MacOS 11.0+. Ease transition. (Also allows mux of multiple loggers: app logger and system logger, for example.) 
    // Entire app should use only 1 subsystem.
    // Each file-type should use only 1 category. (Standard: store, library, document, view, edit)
    // Use only 3 levels. (Standard: debug, info, error)
    public init(category: String, enable: Bool = true) {
        self.log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: category)
        self.enable = enable
    }
    public init(_ log: OSLog, enable: Bool = true) {
        self.log = log
        self.enable = enable
    }
    public func debug(_ message: String) { // Not used in practice. For debug use trace (print) instead. 
        log(level: .debug, message: message)
    }
    public func info(_ message: String) {
        log(message)
    }
    public func error(_ message: String) {
        log(level: .error, message: message)
    }
    private func log(_ message: String) { // Not used in practice. Explicit use info instead.
        log(level: .info, message: message)
    }
    private func log(level: OSLogType, message: String) {
        if enable {
            os_log("%{public}@", log: log, type: level, message) // Forces all messages to be public. (That probably already happens with string interpolation outside of logger, and without use of string access parameter.)
        }
    }
    private let log: OSLog
    private let enable: Bool

    // Move these into MyLogger so clients don't need to import OSLog.
    public struct Logs {
        public static let app = OSLog.app
        public static let model = OSLog.model
        public static let view = OSLog.view
        public static let store = OSLog.store
        public static let text = OSLog.text
        public static let document = OSLog.document
        public static let library = OSLog.library
        public static let edit = OSLog.edit
        public static let textedit = OSLog.textedit
        public static let cloud = OSLog.cloud
        public static let sync = OSLog.sync
    }
    /*
     Not used.
    public static let store = OSLog.store
    public static let document = OSLog.document
    public static let library = OSLog.library
    public static let edit = OSLog.edit
    public static let textedit = OSLog.textedit
    */
}

public struct MySignpost {
    // Similar to new Logger API (WWDC 2020) from IOS 14+ and MacOS 11.0+.
    // Attempt simple version of new Signpost API (WWDC 2018) from IOS 12+ and MacOS 10.14+.
    // Original Unified Logging API (WWDC 2016 OSLog) from IOS 10+ and MacOS 10.12+.
    public init(category: String = "Signpost", enable: Bool = true) {
        self.log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: category)
        self.enable = enable
    }
    public func begin(_ name: StaticString) {
        os_signpost(.begin, log: log, name: name)
    }
    public func end(_ name: StaticString) {
        os_signpost(.end, log: log, name: name)
    }
    private let log: OSLog
    private let enable: Bool
}
