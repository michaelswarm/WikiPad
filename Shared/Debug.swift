//
//  Debug.swift
//  Folder
//
//  Created by Michael Swarm on 28/03/22.
//

//  Move message creation into conditional by passing message function: () -> String
//  How to not require boilerplate copy of signatures into each file?

import Foundation

typealias Message = () -> String // Allows message creation within conditional. Keeps debug conditionals out of main code.
fileprivate let debug = Debug(verbose: true)

// Minimize caller signature. Remove need to use debug instance.
fileprivate func _trace(_ message: Message) { debug.trace(message) } // Simple rename from print to _trace.
fileprivate func _info(_ message: Message) { debug.info(message) }
fileprivate func _error(_ message: Message) { debug.error(message) } // No conflict with other use of error name.
fileprivate func _begin(_ name: StaticString) { debug.begin(name) }
fileprivate func _end(_ name: StaticString) { debug.end(name) }

// Move debug out of Constant.
struct Debug { // Move this into Plumbing. Separate debug from Constant.
    let verbose: Bool // = false
    let log: Bool // = true
    let logger: MyLogger // = MyLogger(MyLogger.Logs.app)
    let signpost = MySignpost()
    
    func trace(_ message: Message) {
        if verbose {
            print(message())
        }
    }
    func info(_ message: Message) {
        if log {
            logger.info(message())
        }
    }
    func error(_ message: Message) {
        if log {
            logger.error(message())
        }
    }
    func begin(_ name: StaticString) {
        if verbose {
            signpost.begin(name)
        }
    }
    func end(_ name: StaticString) {
        if verbose {
            signpost.end(name)
        }
    }
    init(verbose: Bool = false, log: Bool = true, logger: MyLogger = MyLogger(MyLogger.Logs.app)) {
        self.verbose = verbose
        self.log = log
        self.logger = logger
    }
}
