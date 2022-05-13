//
//  TextStoreProtocol.swift
//  Folder
//
//  Created by Michael Swarm on 23/03/22.
//

import Foundation

// High level protocol used by MainModel import-export functions.
// In theory, other text stores could be various databases: defaults, Core Data, CloudKit, etc.
protocol TextStoreProtocol {
    
    // Last modify to entire store. (How to init? To calculate properly, need to scan and sort, and use most recent.) 
    // var modified: Date { get } // Is keys really necessary? (Keys can signal changes on insert-delete, but modified need to signal potential changes to order.)
    
    // Metadata-Key-Name-Title-ID and possible modified?
    // var keys: [String] { get } ??? Keys cache is public, though not part of protocol.
    func getKeys() -> Set<String> // Unordered collection is default, since used by dictionary and database. Can have separate func for ordered collection (getNames, getTitles, etc.)
    func titlesSortedByModified(since: Date?) -> [String] // Used by recent and delta operations.
    
    // Data-Content
    mutating func insert(_: TextModel)
    mutating func modify(_: TextModel)
    mutating func delete(key: String)
    func get(key: String) -> TextModel
}

extension TextStoreProtocol {
    func uniqueTitle(title: String) -> String {
        // Called by updateStore.
        // Results in lower case title if title parameter is lower case.
        // Return String. Original title if no duplicate. Title increment if duplicate.
        let normalTitles = Array(getKeys()).map { $0.lowercased() } // Normalize the titles. // Change from Hypertexts.
        // let normalTitles = dictionary.keys.map { $0.lowercased() } // Normalize the titles.
        var i = 0
        var titleFormat = title.lowercased() // "untitled" // Normalize title parameter.
        while normalTitles.contains(titleFormat) {
            i += 1
            titleFormat = "\(title) \(i)" // "untitled \(i)"
        }
        if i == 0 {
            return title // Original title. Only returned if title already unique.
        } else {
            return titleFormat // Returns title increment
        }
    }
    func checkDuplicateTitle(title: String) -> String? {
        if getKeys().contains(title) {
            return uniqueTitle(title: title) 
        }
        return nil
    }
}
