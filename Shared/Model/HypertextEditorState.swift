//
//  storeState.swift
//  WikiPad
//
//  Created by Michael Swarm on 23/04/22.
//

import Foundation

class HypertextEditorState: ObservableObject { // storeObject? (Share between app and wrappers.)
    
    @Published var showingPopover: Bool = false
    @Published var selection: String // Should selection be optional? (May be other list selections that are optional. This editor title selection is not optional. Must be something for the editor.
    // var newKey = "" // Does this need published? Does it need optional? Just a buffer. Keep it simple. 
    var links: [String]
    var browser: Browser
    
    init(store: TextStoreMemory) {
        let first: String = store.textDictionary.keys.first!
        let recent: String = store.titlesSortedByModified().first! // Sorted by recent.
        let title = recent // or first
        var titles: Set<String> = Set(store.textDictionary.keys)
        titles.remove(title)
        self.selection = title
        self.links = Array(titles)
        self.browser = Browser()
        self.browser.onAppend(title: title)
    }
    // 1 caller: LibraryRowView onTapGesture document.editorState.update(store: document.store, selection: title) // This does not trigger update, even though binding to struct. Why??? (Is this still true?) 

    func update(store: TextStoreMemory, selection: String) { // How many places call this? Only 1 caller
        var titles: Set<String> = Set(store.textDictionary.keys)
        titles.remove(selection)
        let shortestFirst = titles.sorted { $0.count < $1.count } // Sort by length, shortest first, for longest link match.
        self.links = shortestFirst // Array(titles) // Set links before update.
        self.selection = selection // Trigger update last.
        self.browser.onAppend(title: selection) // ???
    }
    func canAdd() -> Bool { return true }
    func canDelete() -> Bool { return true }
}
