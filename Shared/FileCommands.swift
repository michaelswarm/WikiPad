//
//  FileCommands.swift
//  WikiPad
//
//  Created by Michael Swarm on 24/04/22.
//

import SwiftUI

fileprivate let debug = Debug(verbose: true, log: true, logger: MyLogger(MyLogger.Logs.app))

// Minimize caller signature. Remove need to use debug instance.
fileprivate func _trace(_ message: Message) { debug.trace(message) } // Simple rename from print to _trace.
fileprivate func _info(_ message: Message) { debug.info(message) }
fileprivate func _error(_ message: Message) { debug.error(message) } // No conflict with other use of error name.
fileprivate func _begin(_ name: StaticString) { debug.begin(name) }
fileprivate func _end(_ name: StaticString) { debug.end(name) }

struct FileCommands: Commands { // MenuCommands???
    @FocusedValue(\.document) var document // 4. Focused value-focused scene value bug. If in app file, causes debug layout errors and drawing issuses. If in menu commands file ok.

    var body: some Commands {
        CommandGroup(after: .importExport) { // Standard placement for import-export, in file menu after close.
                        
            Divider()
            Button("Add") {
                document?.wrappedValue.add()
            }
            Button("Delete") {
                document?.wrappedValue.delete()
            }
            
            Divider()
            Button("Delete All") {
                print("delete all pressed...")
                // library.deleteAllAction()
            }
            Button("Reset") {
                // library.reset()
            }
            
            Button("Rename") {
                // Works on current text. So old key = editor state selection.
                document?.wrappedValue.editorState.showingPopover = true
                print("Rename pressed...")
            }
            /*.popover(isPresented: $showingPopover) { // Can this be here on a button in a menu? Compiles but does not work. Move to split view.
                RenameView()
            }*/
        }
    }
}
