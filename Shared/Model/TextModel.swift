//
//  TextModel.swift
//  WikiPad
//
//  Created by Michael Swarm on 22/04/22.
//

fileprivate let debug = Debug(verbose: true, log: true, logger: MyLogger(MyLogger.Logs.text)) //

// Minimize caller signature. Remove need to use debug instance.
fileprivate func _trace(_ message: Message) { debug.trace(message) } // Simple rename from print to _trace.
fileprivate func _info(_ message: Message) { debug.info(message) }
fileprivate func _error(_ message: Message) { debug.error(message) } // No conflict with other use of error name.
fileprivate func _begin(_ name: StaticString) { debug.begin(name) }
fileprivate func _end(_ name: StaticString) { debug.end(name) }

import Foundation

struct TextModel: Equatable, Codable { // Here I use TextModel, not Document.
    var title: String { // TextField title.
        didSet {
            modified = Date() // Updates modified whenever title is changed.
        }
    }
    var content: String {
        didSet {
            modified = Date() // Updates modified whenever content is changed.
        }
    }
    var modified: Date
        
    // Explicity default initializer needed since adding init(url:).
    init(title: String, content: String, modified: Date) {
        self.title = title
        self.content = content
        self.modified = modified
    }
}

// Extra complexity for views in separate extension.
extension TextModel: Identifiable {
    var id: String {
        title
    }
}

extension TextModel {
    var first: String? { // This calculated title, except does not handle duplicate titles.
        // May want to enhance to return first non-empty line (exclude blank lines), or string including first non-empty line (include blank lines)?
        let lines = content.lines // String extension var lines.
        return lines.first
    }

    // Check functions. (Check duplicate rename is actually found in library.)
    func checkRename() -> String? {
        // Should appear before modify.
        if let first = first { // Uses calculated value first, from above.
            if title != first {
                _trace { "Rename: from \(title) to: \(first)" }
                return first
            }
        }
        return nil
    }
    // Helper function.
    func contentChangeFirstLine(newTitle: String) -> String {
        // Calculates, but does not actually change content.
        // Called from check rename some case, before rename.
        
        // Version 1.01n: Fix duplicate rename crash.
        // If we know first line, can also replace first.
        // Assume match is first line, which we already know.
        // This does not work. In case of duplicate, the first line has already been change to the new title, but not the unique new title. Because it already has the new title.
        let range = content.range(of: title) // Optional
        let newContent = content.replacingOccurrences(of: title, with: newTitle, options: String.CompareOptions.anchored, range: range)
        // content = newContent // The orginal never changed content, just store content!
        return newContent
    }
}
