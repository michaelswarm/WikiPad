//
//  TextDictionaryStore.swift
//  Folder-Originally FruitListProto
//
//  Created by Michael Swarm on 7/31/20.
//  Adapted from FruitStoreProtocol.swift.
//

//  Responsibilities
//  - TextStoreProtocol Conformance
//  - Assertions
//  - Notifications (state mutation)

//  What is important is memory, not persistence to file or user defaults. 

//  May not be possible to have underlying stateless layer. Dictionary will always be stateful.

//  Questions
//  - What performance? Memory should be fastest.
//  - What memory usage? Important to understand for title index.


import Foundation

fileprivate let debug = Debug(verbose: true, log: true, logger: MyLogger(MyLogger.Logs.store))

// Minimize caller signature. Remove need to use debug instance.
fileprivate func _trace(_ message: Message) { debug.trace(message) } // Simple rename from print to _trace.
fileprivate func _info(_ message: Message) { debug.info(message) }
fileprivate func _error(_ message: Message) { debug.error(message) } // No conflict with other use of error name.
fileprivate func _begin(_ name: StaticString) { debug.begin(name) }
fileprivate func _end(_ name: StaticString) { debug.end(name) }

fileprivate struct Constant {
    static let ext: String = "json"
    static let root: FileManager.SearchPathDirectory = .applicationSupportDirectory // .documentDirectory // Choices: documents, support, caches.
    static let folder: String = "Texts" // Must create this folder in init.
    static let key = "TextStoreMemory"
}

struct TextStoreMemory: Codable, TextStoreProtocol {
    
    // var keys = Set<String>() // Folder does not have keys cache.
    // var modified = Date() // Any operation to dictionary should update date to send to observers. Folder also does not have summary modified.
    
    mutating func insert(_ text: TextModel) {
        textDictionary[text.title] = text
        // keys.insert(text.title)
        // modified = Date()
    }
    
    mutating func modify(_ text: TextModel) {
        // Modify could call modify simple or modify check inline rename. (Later is still problematic. Not sure how to interact with editor state.)
        
        textDictionary[text.title] = text
        // modified = Date()
    }
    
    mutating func modifySimple(_ text: TextModel) {
        textDictionary[text.title] = text
        // modified = Date()
    }

    mutating func modifyCheckInlineRename(_ text: TextModel) {
        /*
         3 cases:
         - 1. save
         - 2. rename (+save) (rename detected)
         - 3. unique rename (+rename +save) (duplicate rename detected)
         */
        
        // No debug or log messages here. Those should be pushed down to low level modify and rename functions.
        switch text.checkRename() { // Check for new title.
            
        case .none: // No new title. Simple save.
            // case 1
            modify(text)
        case .some(let newTitle): // New title.
            switch checkDuplicateTitle(title: newTitle) { // Check if new title is duplicate title.
                
            case .none: // New title, but not duplicate. Simple rename. (No need to change content.)
                // case 2
                rename(oldText: text, newTitle: newTitle, newContent: text.content)
                // rename(from: title, to: newTitle, content: content, modified: modified)
            case .some(let newUniqueTitle): // New unique title. Rename title and change content to match.
                // case 3
                // If duplicate, increment the title (just like default untitled.), and modify content first line to match.
                let newContent = text.contentChangeFirstLine(newTitle: newUniqueTitle) // Does not change content.
                rename(oldText: text, newTitle: newUniqueTitle, newContent: newContent)
                // rename(from: title, to: newUniqueTitle, content: newContent, modified: modified) // Changes store and model content.
            }
        }
        
    }
    
    mutating func rename(oldText text: TextModel, newTitle: String, newContent: String) { // Missing (old) title parameter.
        let newText = TextModel(title: newTitle, content: newContent, modified: Date())
        let oldTitle = text.title
        insert(newText)
        delete(key: oldTitle) // This can break editor state.
        // ISSUE HERE: NO ACCESS TO EDITOR STATE TO CHANGE TITLE.
        // title = newTitle // ??? Editor will use editor state and store dictionary as source of truth.
        // content = newContent // ???
        _info { "Rename: previous \(oldTitle) renamed to current \(newTitle)" }
    }
    /*
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

    
    func get(key: String) -> TextModel {
        textDictionary[key]!
    }
    
    mutating func delete(key: String) {
        textDictionary[key] = nil
        // keys.remove(key) // Need to update keys cache to update list view???
        // modified = Date()
    }
    
    func getKeys() -> Set<String> {
        Set(textDictionary.keys)
    }
    
    // Actual storage here.
    var textDictionary: [String: TextModel] = [
        "test1" : TextModel(title: "test1", content: "test1", modified: Date()),
        "test2" : TextModel(title: "test2", content: "test2", modified: Date()),
        "test3" : TextModel(title: "test3", content: "test3", modified: Date()),
    ]

    // MARK: PERSISTENCE
    // POSSIBLE TO STORE TO FOLDER-FILE. (EASIER TO ASSURE CLEAN UP THAN USER DEFAULTS.)
    
    let location: URL // Should this be state? Why? (Not a folder store.)
    
    // May need different default init.
    init() {
        let root: URL = FileManager.default.urls(for: Constant.root, in: .userDomainMask).first!
        self.location = root.appendingPathComponent(Constant.folder) // Created by load names.
    }
    
    init(root: URL) {
    // init(root: URL = FileManager.default.urls(for: Constant.root, in: .userDomainMask).first!) {
        // let root: URL = FileManager.default.urls(for: Constant.root, in: .userDomainMask).first!
        self.location = root.appendingPathComponent(Constant.folder) // Created by load names.
        // Stored Properties Initialized
        makeFolder()
        loadFromFile()
        // keys = getKeys()
        // modified = Date()
    }
    
    func makeFolder() {
        if !FileManager.default.fileExists(atPath: location.path) {
            try! FileManager.default.createDirectory(at: location, withIntermediateDirectories: false, attributes: nil)
        }
    }
    
    func urlFrom(name: String) -> URL {
        return location.appendingPathComponent(name).appendingPathExtension(Constant.ext)
    }

    mutating func loadFromFile() {
        let url = urlFrom(name: "TextMemoryStore")
        do {
            // New install: File does not exist. Ignore error. 
            let data = try Data(contentsOf: url)
            textDictionary = try JSONDecoder().decode([String: TextModel].self, from: data)
        } catch { }
        
        // /*guard*/ let data = try! /*?*/ Data(contentsOf: url) // else {
            // log error
            // return nil
        //}
    }
    
    func storeToFile() {
        // let data = try! JSONEncoder().encode(textDictionary)
        do {
            let url = urlFrom(name: "TextMemoryStore")
            let data = try JSONEncoder().encode(textDictionary)
            try data.write(to: url)
            _trace { "Store write to url \(url.description)." }
        } catch { }
    }
    
    mutating func load() {
        loadFromFile()
    }
    
    func store() {
        storeToFile()
    }
    
    func storeToUserDefaults() {
        let defaults = UserDefaults.standard
        let data = try! JSONEncoder().encode(textDictionary)
        defaults.setValue(data, forKey: Constant.key)
        _trace { "Store write to user defaults success." }
    }
    mutating func loadFromUserDefaults() {
        let defaults = UserDefaults.standard
        if let data = defaults.object(forKey: Constant.key) as! Data? {
            textDictionary = try! JSONDecoder().decode([String: TextModel].self, from: data as Data)
            _trace { "Load read from user defaults success." }
        }
        // keys = getKeys()
        // modified = Date()
    }
    /* deinit { // Deinitializers may only be declared within a class
        // Bug: Never seems to be called on app quit-terminate? Prefer driver write to be automatic without extra API.
        // Write to User Defaults.
        // May not be enough to guarantee save, especially for IOS, which never shuts down apps.
        let defaults = UserDefaults.standard
        let data = try! JSONEncoder().encode(textDictionary)
        defaults.setValue(data, forKey: key)
        if Constant.log {
            let message = "Deinit write to user defaults success."
            Constant.logger.debug(message)
        }
    } */
    
    // MARK: Titles Sorted By Modified (Custom for Dictionary. Based on Folder.)
    func getModified(from key: String) -> Date? {
        let text = get(key: key)
        return text.modified
    }
    func loadNamesModified() -> [String: Date] {
        _begin("Load Names Modified")
        let names = Array(getKeys()) // ~30ms for 6k files. Filesystem caches names.
        // Use reduce(into:_:) to transform array to dictionary.
        // let x = names.reduce(into: [:]) { $0[$1] = getModified(from: $1)! } // Shortest versions with $0, $1 syntax, but loses description.
        /* let y = names.reduce(into: [:]) { partialResult, name in
            partialResult[name] = getModified(from: name)!
        } */ // Slightly shorter version with more type inference.
        let namesModified: [String: Date] = names.reduce(into: [String: Date]()) { result, name in // ~500ms scan for 6k files.
            result[name] = getModified(from: name)!
        }
        _end("Load Names Modified")
        return namesModified
    }
    func titlesSortedByModified(since: Date? = nil) -> [String] {
        _begin("Names Sorted By Modified")
        // Dictionary of [names: modified]
        let namesModified = loadNamesModified() // ~500ms scan for 6k files (folder).
        // Dictionary filtered by value (> since).
        var namesModifiedSince = [String: Date]()
        switch since {
        case .some(let since):
            namesModifiedSince = namesModified.filter { (string, date) in
                date >= since //  (what about equal?)
            }
        case .none:
            namesModifiedSince = namesModified // Default include all, don't filter. (Faster to just skip filter if nil.)
        }
        // Dictionary keys sorted by value (by modified).
        // less than = oldest first, greater than = newest first
        let sortedKeysSince = Array(namesModifiedSince.keys).sorted(by: { namesModifiedSince[$0]! > namesModifiedSince[$1]!  }) // ~160ms sort for 6k files. Majority of time spent in scan, not sort.
        // var sortedKeys = Array(namesModified.keys).sorted(by: { namesModified[$0]! < namesModified[$1]! })
        _end("Names Sorted By Modified")
        return sortedKeysSince
    }
}

// TBD: Read-Write URL (First implementation read-write to user defaults. Better to read-write to URL.
// Can copy boilerplate from SyncState. 
