//
//  HypertextEditor.swift
//  TextLibraryProtoIOS
//
//  Created by Michael Swarm on 9/1/20.
//

fileprivate let debug = Debug(verbose: true, log: true, logger: MyLogger(MyLogger.Logs.edit))

// Minimize caller signature. Remove need to use debug instance.
fileprivate func _trace(_ message: Message) { debug.trace(message) } // Simple rename from print to _trace.
fileprivate func _info(_ message: Message) { debug.info(message) }
fileprivate func _error(_ message: Message) { debug.error(message) } // No conflict with other use of error name.
fileprivate func _begin(_ name: StaticString) { debug.begin(name) }
fileprivate func _end(_ name: StaticString) { debug.end(name) }

import SwiftUI
import os.log

// MyTextView: Text View (NSTextView) within Scroll View (NSScrollView).
// Interface Builder always creates these together.
// Must create separate and assemble in code.

// ? Bug: Something is wrong about the binding of text.
// ? First letter of edit works, but then cursor-selection jumps to end of document.

// Need my own wrapper to support Hypertexts. Do not know how to extend SwiftUI TextEdit.

struct HypertextEditor: UIViewRepresentable {
    
    /* Fonts and text storage edit processing moved into extensions for NSMutableString and ParagraphStyle.
    var bodyFontOSX: NSFont? {
        let userFontSize = 18.0 // // app.system.settings.textSize (bump from 16.0)
        let bodyFont = NSFont.userFont(ofSize: CGFloat(userFontSize)) // Convert Double(64) to CGFloat(32 or 64)
        return bodyFont
    }
    var header1FontOSX: NSFont? {
        let userFontSize = 28.0 // // app.system.settings.textSize (bump from 16.0)
        let bodyFont = NSFont.userFont(ofSize: CGFloat(userFontSize)) // Convert Double(64) to CGFloat(32 or 64)
        return bodyFont
    }
    */
    
    @Binding var text: String
    @ObservedObject var libraryState: HypertextEditorState
    
    init(text: Binding<String>, libraryState: HypertextEditorState) {
        _text = text
        self.libraryState = libraryState
    }
    class Coordinator: NSObject, UITextViewDelegate {
        @Binding var text: String
        @ObservedObject var libraryState: HypertextEditorState
        
        // @Binding var selection: NSRange

        // Edit Processing Extension also needs access to fonts. How to avoid duplicate code???
        /* Fonts and text storage edit processing moved into extensions for NSMutableString and ParagraphStyle.
        var bodyFontOSX: NSFont? {
            let userFontSize = 18.0 // // app.system.settings.textSize (bump from 16.0)
            let bodyFont = NSFont.userFont(ofSize: CGFloat(userFontSize)) // Convert Double(64) to CGFloat(32 or 64)
            return bodyFont
        }
        var header1FontOSX: NSFont? {
            let userFontSize = 28.0 // // app.system.settings.textSize (bump from 16.0)
            let bodyFont = NSFont.userFont(ofSize: CGFloat(userFontSize)) // Convert Double(64) to CGFloat(32 or 64)
            return bodyFont
        }
        */
        
        init(text: Binding<String>, libraryState: HypertextEditorState) {
            _text = text
            self.libraryState = libraryState
        }
        // UITextView
        func textViewDidChange(_ textView: UITextView) {
            // guard textView.text != text else { return } // Is this needed? Not present OSX version?
            text = textView.text // text vs string
        }
        // NSTextView
        // Maybe use text storage (delegate?) functions?
        /*func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? UITextView else { return }
            text = textView.text // text vs string
        }*/
        // UITextView
        func textViewDidChangeSelection(_ textView: UITextView) {
            // guard textView.selectedRange != selection else { return }
            // guard textView.selectedRange() != selection else { return } // Selection equality check, based on similar text equality check from https://onmyway133.github.io/blog/How-to-edit-selected-item-in-SwiftUI/.

            // selection = textView.selectedRange
            //selection = textView.selectedRange()
        }
        // NSTextView
        /*public func textViewDidChangeSelection(_ notification: Notification) {
            guard let textView = notification.object as? UITextView else { return }
            guard textView.selectedRange != selection else { return }
            // guard textView.selectedRange() != selection else { return } // Selection equality check, based on similar text equality check from https://onmyway133.github.io/blog/How-to-edit-selected-item-in-SwiftUI/.

            selection = textView.selectedRange
            //selection = textView.selectedRange()
        }*/
        // UITextView
        func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
            _trace { "Link clicked: \(URL), absoluteString: \(URL.absoluteString)" }
            
            if URL.absoluteString.starts(with: "http://") { // External Link
                _trace { "External link clicked: \(URL.absoluteString)" }
                return true // Not handled. Default open Safari.
            } else if URL.absoluteString.starts(with: "https://") { // External Link
                _trace { "External link clicked: \(URL.absoluteString)" }
                return true // Not handled. Default open Safari.
            } else {
                _trace { "Internal link clicked: \(URL.absoluteString)" }
                let title = URL.absoluteString.removingPercentEncoding!
                libraryState.selection = title // How does this update the links??? Yet it appears to do so???
                return false // Did handle the link.
            }
            
            return false // Did not handle the link. By default open URL in Safari.
        }
        // NSTextView: Different function signature all together.
        /*public func textView(_ textView: UITextView, clickedOnLink link: Any, at charIndex: Int) -> Bool {
            // Value of NSLinkAttributeName is NSURL or NSString or nil.
            if let linkString = link as? String { // link is value of NSLinkAttributeName, which is just a string.
                // Hypertexts used forced cast above without problems. (Was never NSURL or nil. Any URL was always encoded as percent encoded string.)
                print("Link clicked: \(linkString)")
                
                if linkString.starts(with: "http://") { // External Link
                    return false // Not handled. Default open Safari.
                } else if linkString.starts(with: "https://") { // External Link
                    return false // Not handled. Default open Safari.
                } else {
                    let title = linkString.removingPercentEncoding!
                    library.selection = title
                    return true // Did handle the link.
                }
                
                //library.selection = linkString // This should cause document change???
                // return true // Did handle the link.
            }
            print("Link clicked. Can not decode: \(link)")
            return false // Did not handle the link.
            
            // How did Hypertexts or Text Library handle case insensitive lookups?
        }*/
    }
    
    func makeCoordinator() -> HypertextEditor.Coordinator {
        print("Make Coordinator...")
        return Coordinator(text: $text, libraryState: libraryState)

        // return Coordinator(text: $text, /*selection: $selection,*/ library: $library, document: $document)
    }
    func makeUIView(context: UIViewRepresentableContext<HypertextEditor>) -> UITextView { // -> NSScrollView
        print("Make UIView...")
        // Views from code may not have same defaults as views from Interface Builder.
        // Code below adapted from Apple Developer Text In Scroll View
        // UIKit UITextView has scrolls by default: scrollEnabled = true, userInteractionEnabled = true
        
        //let scrollView = NSScrollView(frame: .zero)
        //let contentSize = scrollView.contentSize
        //scrollView.borderType = .noBorder
        //scrollView.verticalScroller = .some(NSScroller()) // ???
        //scrollView.horizontalScroller = .none
        //scrollView.autoresizingMask = .width // .height // Grow and shrink on resize.
        
        let textView = UITextView(frame: .zero)
        //let textView = NSTextView(frame: NSMakeRect(0, 0, contentSize.width, contentSize.height) /*, textContainer: textContainer*/)
        //textView.minSize = NSMakeSize(0.0, contentSize.height)
        //textView.maxSize = NSMakeSize(.greatestFiniteMagnitude, .greatestFiniteMagnitude)
        //textView.isVerticallyResizable = true
        //textView.isHorizontallyResizable = false
        textView.autoresizingMask = .flexibleWidth // Was .width
        //textView.textContainer?.size = NSMakeSize(contentSize.width, .greatestFiniteMagnitude)
        //textView.textContainer?.widthTracksTextView = true
        
        // Assemble scroll view and text view
        //scrollView.documentView = textView

        textView.delegate = context.coordinator // Text View Delegate causes edit selection jump. Not Text Storage Delegate!
        textView.textStorage.delegate = context.coordinator // Causes insert edit cursor to jump to end.

        /*if #available(OSX 10.16, *) {
            _ = NSFont.preferredFont(forTextStyle: .title1, options: [:] ) // What are options? Try supply empty options dictionary. Not present in IOS API? Font not used anyway, even in IOS version. (Perhaps I never set font in view correctly?)
        } else {
            // Fallback on earlier versions
        } // 10.16+ Seems MacOS finally gets dynamic type, or at least the type styles???
         */
        textView.adjustsFontForContentSizeCategory = true // IOS API
        
        textView.font = UIFont.preferredFont(forTextStyle: .body) // bodyFontOSX // No dynamic type?
        textView.textColor = UIColor.label // Should be default.
        
        // return scrollView
        return textView
    }
    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<HypertextEditor>) {
        print("Update UIView...")
        let textView = uiView // as! UITextView
        guard textView.text != text else { return }
        //guard textView.string != text else { return } // Text equality check from https://onmyway133.github.io/blog/How-to-edit-selected-item-in-SwiftUI/. Resolved edit selection jump issue.
        textView.text = text // Change text.
    }
}

// Largely same as OSX (delegate is still NSTextStorageDelegate), except for couple of parameter renames (NSTextStorage.EditActions), and dynamic text UIFonts instead of NSFonts.
extension HypertextEditor.Coordinator: NSTextStorageDelegate {
    
    // Text Storage = Text View Model
    // No access to selection here. (Use text view delegate for selection.)
    
    // Only 2 functions: will Process Editing and did Process Editing. Nothing related to selection.
    
    /* In OSX at least, edits in will process editing cause cursor to move to end of range. Does not matter if just attributes. Does not matter if set or just add attribute. Used did process editing instead.
     func textStorage(_ textStorage: NSTextStorage, willProcessEditing editedMask: NSTextStorage.EditActions, range editedRange: NSRange, changeInLength delta: Int) {
     <#code#>
     }*/
    
    func textStorage(_ textStorage: NSTextStorage, willProcessEditing editedMask: NSTextStorage.EditActions, range editedRange: NSRange, changeInLength delta: Int) {
        
        // text = textStorage.string // DESIGN ERROR: This causes infinite update loop.
        
        //_trace { "edited range: \(editedRange.location), \(editedRange.length), change in length: \(delta), total length: \(textStorage.string.count)" }

    }

    // Why not error for Hypertexts (Text Wiki)?
    //'NSTextStorageEditActions' has been renamed to 'NSTextStorage.EditActions'
    // Instance method 'textStorage(_:willProcessEditing:range:changeInLength:)' nearly matches optional requirement 'textStorage(_:willProcessEditing:range:changeInLength:)' of protocol 'NSTextStorageDelegate'
    func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorage.EditActions, range editedRange: NSRange, changeInLength delta: Int) {
        // Edited mask values are edited characters or edited attributes. Not useful.
        // _trace { "edited range: \(editedRange.location), \(editedRange.length), change in length: \(delta), total length: \(textStorage.string.count)" }
        // text = textStorage.string // DESIGN ERROR: This causes infinite update loop.
        
        /*
        switch editedMask {
        case .editedCharacters:
            _trace { "Edited Characters" }
        case .editedAttributes:
            _trace {  "Edited Attributes" }
        default:
            _trace { "Edited Characters and Attributes" }
        }
        
        if editedRange.length == textStorage.string.count { // Load
            _trace { "Load" }
        }
        if editedRange.length == delta { // Add
            _trace { "Add" }
        }
        if editedRange.length == 0 { // Delete
            _trace { "Delete" }
        }
        */
        // May also be changes that combine add and delete???
        
        textStorage.processEdit(editedRange: editedRange, keywords: libraryState.links)
    }
}

