//
//  LibraryModel.swift
//  WikiPad
//
//  Created by Michael Swarm on 22/04/22.
//

import Foundation

struct TextStore: Codable { // Perhaps this is not library, but store? (And selection is separate, in top level document-library.)
    
    var textStore: [String: TextModel] = [
        "test1" : TextModel(title: "test1", content: "test1", modified: Date()),
        "test2" : TextModel(title: "test2", content: "test2", modified: Date()),
        "test3" : TextModel(title: "test3", content: "test3", modified: Date()),
    ]
}
