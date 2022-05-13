//
//  SplitNavigationView.swift
//  WikiPad
//
//  Created by Michael Swarm on 26/04/22.
//

import SwiftUI

struct SplitNavigationView: View {
    @Binding var document: WikiPadDocument
    @EnvironmentObject var editorState: HypertextEditorState
    
    // Calculated bindings as calculated vars. (Must be a better way???) 
    var bindingShowingPopover: Binding<Bool> {
        Binding<Bool>(
            get: { self.document.editorState.showingPopover },
            set: { self.document.editorState.showingPopover = $0 }
        )
    }
    /*var bindingNewTitle: Binding<String> {
        Binding<String>(
            get: { self.document.editorState.newKey },
            set: { self.document.editorState.newKey = $0 }
        )
    }*/
    
    var body: some View {
        NavigationView {
            SidebarList(document: $document)
            
            #if os(iOS)
                .frame(width: 300) // Default seems to be 100-150?
            #endif
#if os(OSX)
                .frame(minWidth: 200) // Default seems to be 100-150?
#endif
            // Issue: How to bind to dictionary value???
            TextCanvas(document: $document)
            /*HypertextEditor(text: Binding<String>(
                get: { self.document.store.textDictionary[self.document.editorState.selection]?.content ?? "No content" },
                set: { self.document.store.textDictionary[self.document.editorState.selection]?.content = $0 }
            ), libraryState: document.editorState)*/
        }
        .popover(isPresented: bindingShowingPopover) {
            RenameView(document: $document) 
        }
        
        // This works, but not what I want. Is bubble popup. No way to dismiss. 

        // 'navigationBarLeading' is unavailable in macOS
        // SwiftUI v3 supports platform conditional modifiers for postfix member expressions and modifiers.
        #if os(iOS)
        /*.toolbar {
            ToolbarItem(placement: side == .left ? .navigationBarLeading : .navigationBarTrailing ) {
                ToolbarView(document: $document)
            }
        }*/
        .toolbar {
            ToolbarItem(placement: .navigation) { // Preceeds the document file name.
                NavigationBar(document: $document, editorState: document.editorState)
            }
            // Document title is where I would really like page title to be.

            // Seems Mac document-based has option of principle (center) or trailing (right), but not both.
            // Seems can not combine .principal (center) and .primaryAction (trailing). Result is center.
            // Order is important for combined placements. (And .principle and .primaryAction are combined on Mac.)

            ToolbarItem(placement: .navigation) { // What if navigation instead of primaryAction? This puts document title with navigation controls (back-forward). And pushes file name to middle. Like this.
                Titlebar(document: $document, editorState: document.editorState)
                /*Titlebar(title: Binding<String>(
                    get: { self.document.editorState.selection }, // Why is this not updating???
                    set: { self.document.editorState.selection = $0 }
                )) // Why is this possible, but not $document.editorState.selection? (This changes the selection, not the title!)
                */
            }
            ToolbarItem(placement: .primaryAction) { // .automatic (Mac right), .primaryAction (Mac right), .principal (Mac middle), .navigation (Mac left)
                Toolbar(document: $document, editorState: document.editorState)
            }
        }
        #endif
        #if os(OSX)
        // Toolbar MacOS Monterey very tall!
        .toolbar {
            ToolbarItem(placement: .navigation) { // Preceeds the document file name.
                NavigationBar(document: $document, editorState: document.editorState)
            }
            // Document title is where I would really like page title to be.

            // Seems Mac document-based has option of principle (center) or trailing (right), but not both.
            // Seems can not combine .principal (center) and .primaryAction (trailing). Result is center.            
            // Order is important for combined placements. (And .principle and .primaryAction are combined on Mac.)

            ToolbarItem(placement: .navigation) { // What if navigation instead of primaryAction? This puts document title with navigation controls (back-forward). And pushes file name to middle. Like this. 
                Titlebar(document: $document, editorState: document.editorState)
                /*Titlebar(title: Binding<String>(
                    get: { self.document.editorState.selection }, // Why is this not updating???
                    set: { self.document.editorState.selection = $0 }
                )) // Why is this possible, but not $document.editorState.selection? (This changes the selection, not the title!)
                */
            }
            ToolbarItem(placement: .primaryAction) { // .automatic (Mac right), .primaryAction (Mac right), .principal (Mac middle), .navigation (Mac left)
                Toolbar(document: $document, editorState: document.editorState)
            }            
            // .status (Mac right)
            // Can not center title and right align buttons without making a single view. It is what it is for now.
        }
        #endif
    }
}

/*struct SplitNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        SplitNavigationView(document: .constant(WikiPadDocument()))
    }
}*/
