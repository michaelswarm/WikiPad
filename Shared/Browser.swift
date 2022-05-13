//
//  Browser.swift
//  CoreDataOSX
//
//  Created by Michael Swarm on 6/22/18.
//  Copyright © 2018 Michael Swarm. All rights reserved.
//
//  Version 1.01a: On remove use filter instead of enumeration.

/*
 Based on BrowseList, except separates index from app.current and notification. (BrowseList was tightly coupled to the application, which could not function without a browseList.)
 Browser operations should first modify the browser, then modify app.current.
 */

/*
 Mar 2021 Port to Text Library 5.
 Class or struct? Keep class at least for first port.
 Add nested typealias Title = String.
 Add Constant.verbose to quite development prints.
 Remove \(String(describing: Browser.self)).
 
 How does browser integrate into rest of project?
 */

import Foundation

fileprivate struct Constant {
    static let verbose = true
}

// Better as struct? For now, just get integrated and working...
class Browser: ObservableObject { // Added ObservableObject for SwiftUI. 
    // Why not just use browser: Array<String> and browserIndex: Int
    
    typealias Title = String
    
    public var title: String { array[index] }
    public var array = [Title]()
    @Published public var index = 0 // Added @Published for SwiftUI.
    
    // ???
    private let firstIndex = 0 // = array.startIndex
    private var lastIndex: Int {
        // Note: array.endIndex = past end, which is why use separate lastIndex.
        return array.count - 1 // For empty = -1. For start-home = 0
        /*switch array.count {
         case 0: return 0 // Otherwise array.count - 1 would return -1.
         default: return array.count - 1
         }*/
    }
    
    func canBack() -> Bool {
        // let ret: Bool = index > firstIndex
        // print("\(String(describing: self)).\(#function)  \(title) \(index) \(firstIndex) \(ret)")
        return (index > firstIndex)
    }
    func canForward() -> Bool {
        // let ret: Bool = index < lastIndex
        // print("\(String(describing: self)).\(#function)  \(title) \(index) \(lastIndex) \(ret)")
        return (index < lastIndex)
    }
    
    private func append(title: Title) {
        array.append(title)
        index = lastIndex // Given from append.
        // print("\(String(describing: self)).\(#function)  \(title) \(index) \(firstIndex)")
    }
    private func removeAll(title: Title) {
        // Separate from on remove, which also uses the same array filter statement.
        // This function is work in progress.
        // Do not understand how removing items affects index, which it certainly does.
        let current = array[index]
        
        array = array.filter { $0 != title } // Delete all instances of title. ($0 == title returns array with only title. $0 != title removes title.)
        // System check valid index currently used to fix up if out of bounds index.
        // Maybe better way? Don't know whether removed instances were before or after current index.
        // What about index??? Does it matter if array[index] == title???
    }
    private func removeCurrentUntilLast() {
        if index <= lastIndex { // Move these checks to access function (onDelete)?
            // array.removeRange changed to array.removeSubrange
            array.removeSubrange(index...lastIndex) // trim from index to end
            //let x = array.endIndex // Should be 0? (endIndex != count)
            index = lastIndex // Given from remove.
        }
    }
    private func removeNextUntilLast() {
        if index < lastIndex { // Move these checks to access function (onAdd)?
            array.removeSubrange(index + 1...lastIndex) // trim from after index to end
            index = lastIndex // Given from remove.
        }
    }
}

extension Browser {
    // Convenience
    
    // MARK: Public
    // Uses private functions.
    func onBack() {
        // Should always be preceeded by canBack() check, to enable button.
        if Constant.verbose { print("\(#function) Before array: \(array), index: \(index)") }
        index -= 1
        let title = array[index] // Index not safe unless preceeded by canBack() check.
        if Constant.verbose { print("\(#function) Page: \(title)") }
        if Constant.verbose { print("\(#function) After array: \(array), index: \(index)") }
        postBrowserChangeNotification()
    }
    func onForward() {
        // Should always be preceeded by canForward() check, to enable button.
        if Constant.verbose { print("\(#function) Before array: \(array), index: \(index)") }
        index += 1
        let title = array[index] // Index not safe unless preceeded by canForward() check.
        if Constant.verbose { print("\(#function) Page: \(title)") }
        if Constant.verbose { print("\(#function) After array: \(array), index: \(index)") }
        postBrowserChangeNotification()
    }
    func onAppend(title: Title) {
        // Trim from index and start new branch.
        // Used by Select, Add and Link operations.
        if Constant.verbose { print("\(#function) Page: \(title)") }
        if Constant.verbose { print("\(#function) Before array: \(array), index: \(index)") }
        switch array.isEmpty {
        case true: // Startup case
            append(title: title)
        case false: // Add, Select, Link
            removeNextUntilLast()
            append(title: title)
        }
        if Constant.verbose { print("\(#function) After array: \(array), index: \(index)") }
        postBrowserChangeNotification()
    }
    
    func onRemove() {
    // Add parameter title: String, so that other callers that delete texts, besides the Content MVC UI, can remove those titles from the browser, if they exist there.
        
        let title = array[index] // Index not safe unless preceeded by canBack() check.
        if Constant.verbose { print("\(#function) Page: \(title)") }
        if Constant.verbose { print("\(#function) Before array: \(array), index: \(index)") }

        let deleteTitle = title // Save title for filter.
        removeCurrentUntilLast() // removeCurrentUntilLast???
        /*for (index, title) in array.enumerated() {
            let title = array[index] // Index not safe unless preceeded by canBack() check. // Index out of range here. Perhaps can not modify index after it is enumerated? (How to delete all occurances of item in array?)
            if title == deleteTitle {
                array.remove(at: index) // Remove all instances of title.
                self.index -= 1 // Must also decrement index.
            }
        }*/
        // Above does not work.
        array = array.filter { $0 != deleteTitle } // Delete all instances of title. ($0 == title returns array with only title. $0 != title removes title.)
        // array = array.filter { $0 == deleteTitle } // Delete all instances of title.
        if Constant.verbose { print("\(#function) After array: \(array), index: \(index)") }
        postBrowserChangeNotification() // Should we post only if browser actually changed?
    }
    func onRename(fromTitle: Title, toTitle: Title) {
        // Document MVC will rename current document on save. At this time, the next title selection has already been made, perhaps be browser back or forward.
        // Rename current at index only. Also should rename all occurances. (Similar to onDelete.)
        //array.remove(at: index) // Remove old title.
        //array.insert(title, at: index) // Replace with new title.
        if Constant.verbose { print("\(#function) From: \(fromTitle) To: \(toTitle)") }
        
        // let renameTitle = title
        for (index, title) in array.enumerated() {
            // let title = array[index] // Index not safe unless preceeded by canBack() check.
            if title == fromTitle {
                array.remove(at: index) // Remove old title.
                array.insert(toTitle, at: index) // Replace with new title.
            }
        }
        // Could also use array.map?
        // postBrowserChangeNotification() // Do we really need browser change? Its size and index did not change, only the contents.
    }
    
    private func postBrowserChangeNotification() {
        // index is Int, which is not NSObject.
        // let userInfo: [String: [String]] = ["Index": index]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "BrowserChange"), object: self, userInfo: nil)
    }

}

