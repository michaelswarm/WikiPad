//
//  WikiPadDocument.swift
//  Shared
//
//  Created by Michael Swarm on 22/04/22.
//

fileprivate let debug = Debug(verbose: true, log: true, logger: MyLogger(MyLogger.Logs.sync)) // .cache?

// Minimize caller signature. Remove need to use debug instance.
fileprivate func _trace(_ message: Message) { debug.trace(message) } // Simple rename from print to _trace.
fileprivate func _info(_ message: Message) { debug.info(message) }
fileprivate func _error(_ message: Message) { debug.error(message) } // No conflict with other use of error name.
fileprivate func _begin(_ name: StaticString) { debug.begin(name) }
fileprivate func _end(_ name: StaticString) { debug.end(name) }

import SwiftUI
import UniformTypeIdentifiers

// Bug: Will new and save, but not open.
// 2022-07-10 11:33:41.328860-0500 WikiPad[1151:20916] com.example.wikipad is not a valid allowedFileType because it doesn't conform to UTTypeItem
extension UTType {
    static var wikipad: UTType {
        UTType(exportedAs: "com.example.wikipad")
    }
    static var exampleText: UTType {
        UTType(importedAs: "com.example.plain-text")
    }
}

struct WikiPadDocument: FileDocument {
    
    var store: TextStoreMemory // Why does change here trigger update?
    let editorState: HypertextEditorState
    
    // No need to store any of this, so no need to be in library. Document serves as top level value. (These could also be in app?)
    
    /*
    var selection: String = "test1" // Must match key in textStore.
    var links: [String] = ["test2", "test3"] // UIKIT-APPKIT wrappers do not have notification mechanism. Can make from bindings, and write bindings, but not read bindings when update?
    
    func getLinks() -> [String] {
        links
    }
    
    mutating func setSelection(_ newValue: String) { // Try mutating function instead of var and calculated value.
        var keys = Set(library.textStore.keys)
        keys.remove(newValue)
        links = Array(keys)
        selection = newValue // Try change selection last, so that new keysExcludeSelection is already set.
        print("Document links: \(links), selection: \(selection)") 
    }
    */
    // This seems not to get updated as selection changes. Move selection to document? (Should not get saved anyhow.)
    var contentSelection: NSRange = NSRange() // Is NSRange Codeable???
    
    init() {
        self.store = TextStoreMemory()
        self.editorState = HypertextEditorState(store: store)

        /*
        // How to sync model and state? Clearly state is derived from model. Ideally would be calculated value. 
        let selection: String = library.textStore.keys.first!
        var keys = Set(library.textStore.keys)
        keys.remove(selection)
        let links: [String] = Array(keys)
        libraryState = LibraryState(selection: library.textStore.keys.first!, links: Array(Set(library.textStore.keys).remove(library.textStore.keys.first!)))
        */
    }
    
    static var readableContentTypes: [UTType] { [.wikipad] }
    
    init(configuration: ReadConfiguration) throws {
        _begin("FileWrapperRead")
        let start = Date()

        //self.selection = "test1" // Must match key in textStore.
        guard let data = configuration.file.regularFileContents
        else { throw CocoaError(.fileReadCorruptFile) }
        /*
         Thread 2: Fatal error: 'try!' expression unexpectedly raised an error: Swift.DecodingError.keyNotFound(CodingKeys(stringValue: "contentSelection", intValue: nil), Swift.DecodingError.Context(codingPath: [], debugDescription: "No value associated with key CodingKeys(stringValue: \"contentSelection\", intValue: nil) (\"contentSelection\").", underlyingError: nil))
         */
        self.store = try! JSONDecoder().decode(TextStoreMemory.self, from: data) // Improve this with error log. Need to better understand try.
        // _error { "Error decoding contents of file: \(configuration.file.filename!). Error: \(error.localizedDescription)" }
        self.editorState = HypertextEditorState(store: store)

        let end = Date()
        let seconds = end.timeIntervalSince(start)
        _trace { "Document read (sec): \(seconds.formatted())" }
        _end("FileWrapperRead")
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        _begin("FileWrapperWrite")
        let start = Date()
        
        // Impossible to mutate prior to write.
        // checkRename() // Cannot use mutating member on immutable value: 'self' is immutable
        let data = try! JSONEncoder().encode(store)
        // _error { "Error encoding-writing contents of file: \(configuration.existingFile!.filename!). Error: \(error.localizedDescription)" }
        
        let end = Date()
        let seconds = end.timeIntervalSince(start)
        _trace { "Document write (sec): \(seconds.formatted())" }
        _end("FileWrapperWrite")

        return .init(regularFileWithContents: data) // Improve this with error log. Need to better understand try.
    }
    
    // var modified: Date = Date()
}

extension WikiPadDocument {
    // MARK: OPERATIONS
    mutating func add() {
        var newTitle = ""
        let contentSelection: String? = ""
        switch contentSelection {
        case .some(let contentSelection):
        if !contentSelection.isEmpty { newTitle = contentSelection } // Set new title to content selection.
        else { newTitle = store.uniqueTitle(title: "untitled") } // Cursor, no selection.
        case .none:
            newTitle = store.uniqueTitle(title: "untitled")
        }
        let text = TextModel(title: newTitle, content: "content", modified: Date())
        store.insert(text)
        _info { "Add text: \(text.title)" }
        editorState.selection = newTitle
        editorState.update(store: store, selection: editorState.selection) // Fix to add to links.
        editorState.browser.onAppend(title: newTitle)

        /*
        let unique = store.uniqueTitle(title: "untitled")
        let text = TextModel(title: unique, content: "content", modified: Date())
        store.insert(text)
        // modified = Date()
        */
    }
    mutating func delete() {
        let title = editorState.selection // { // Need editor state here. (Should selection be optional?)
            store.delete(key: title)
            _info { "Delete text: \(title)" }
            // TBD: Set editor title...
            setStartTitle()
            editorState.update(store: store, selection: editorState.selection) // Fix to remove from links.
            editorState.browser.onRemove() // Knows title from current index.
            // modified = Date()
        //}
    }
    // Add does not change editor. Delete changes editor here. (Might want separate library delete, not what is present in editor? If delete what is present in editor, present a destructive delete warning?)
    
    mutating func rename(oldTitle: String, newTitle: String) {
        print("Document rename \(oldTitle) to \(newTitle)...")
        let old = store.get(key: oldTitle)
        let new = TextModel(title: newTitle, content: old.content, modified: Date())
        store.insert(new)
        store.delete(key: oldTitle)
        editorState.selection = newTitle // Could change selection between insert and delete. But view will probably not be updated until mutating func is complete. Then will update from mutated store with new title. Assume mutating function operates like transaction?
        editorState.update(store: store, selection: editorState.selection) // Fix to add-remove to-from links.
        editorState.browser.onRename(fromTitle: oldTitle, toTitle: newTitle)
    }
    func back() {
        print("Back...")
        editorState.browser.onBack()
        editorState.selection = editorState.browser.array[editorState.browser.index]
    }
    func forward() {
        print("Forward...")
        editorState.browser.onForward()
        editorState.selection = editorState.browser.array[editorState.browser.index]
    }
}

extension WikiPadDocument {
    // MARK: OPERATION SUB-FUNCTIONS
    
    // Called by add()
    mutating func setStartTitle(post: Bool = true) {
        // Called by deleteAction
        // Should be preceeded by check for empty database
        func checkDatabaseNotEmpty() {
            if store.getKeys().isEmpty {
                // spotlight.deleteAll() // Assures Spotlight index empty too.
                let newText = TextModel(title: "Default", content: "Default\n", modified: Date())
                store.insert(newText)
            }
        }
        checkDatabaseNotEmpty()
        
        // Similar code used in init(). Should single unified setStartTitle() be used?
        let first = store.getKeys().first!
        let recent = store.titlesSortedByModified().first! // Sorted most recent.
        let title = recent // or first
        editorState.selection = title
        _trace { "Library opened document '\(title)'." }
    }
    
    // Remainder of extension code is not used. Intended for inline rename.
    mutating func checkRename() {
        let key = ""
        let new = store.get(key: key) // new is not a keyword!
    }
    
    // newContent, to distinguish from content (old content). Ideally we don't further change modified.
    /*
    func rename(newTitle: String, newContent: String) {
        let newText = TextStructure(title: newTitle, content: newContent, modified: modified)
        let oldTitle = title
        store.insert(text: newText)
        store.delete(title: oldTitle)
        title = newTitle
        content = newContent
        cancelTimer()
        if log {
            saveCount += 1
            let message = "Document '\(oldTitle)' renamed to '\(newTitle)' and saved. Save count: \(saveCount)."
            logger.info(message)
        }
    }
    func rename(from: String, to: String, content: String, modified: Date) {
        // More complex save. Rename-save gets logged here.
        // Rename changes document (title and content), but only after change to store.
        // Rename must change title. (That is meaning of rename.)
        // Rename may optionally change content. (In case of making unique name after finding duplicate title.)
        
        let oldTitle = from // Used to delete
        let newTitle = to // Used to insert

        // Should model change before or after storage change? Which is truth?
        // 1st change store.
        let renamedText = TextStructure(title: newTitle, content: content, modified: modified)
        store.insert(text: renamedText)
        store.delete(title: oldTitle)
        // 2nd change model.
        self.title = newTitle // Rename must change title. (That is meaning of rename.)
        self.content = content // Rename may optionally change content. (In case of making unique name after finding duplicate title.)
        cancelTimer() // Cancel timer from content change. Else causes extra save. (Or even save loop.)
        if log {
            saveCount += 1
            let message = "Document '\(oldTitle)' renamed to '\(newTitle)' and saved. Save count: \(saveCount)."
            logger.info(message)
        }
    }
    */
}
