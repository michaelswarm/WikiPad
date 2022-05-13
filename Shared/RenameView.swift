//
//  RenameView.swift
//  WikiPad
//
//  Created by Michael Swarm on 27/04/22.
//

/*
 Popover requires state in 4 places:
 1. Hypertext editor state (var showPopover) This is state.
 2. File commands (set true) This is trigger.
 3. Rename view (set false) This is popup itself.
 4. Split navigation view (popover) This is parent view.
 One of few examples in SwiftUI where doing something simple requires touching 4 files.
 */

/*
 How to decide with of text field?
 How to title popup?
 
 struct ContentView: View {
     @State private var showingPopover = false

     var body: some View {
         Button("Show Menu") {
             showingPopover = true
         }
         .popover(isPresented: $showingPopover) {
             Text("Your content here")
                 .font(.headline)
                 .padding()
         }
     }
 }

 */

import SwiftUI

struct RenameView: View {
    @Binding var document: WikiPadDocument // Always value.
    // var oldKey: String = "oldKey" // This is fixed value. Not used. 
    @State var newKey: String = "" // Binding not needed. 
    @EnvironmentObject var editorState: HypertextEditorState
    // @FocusedValue(\.document) var document // Optional remains nil.

    var body: some View {
        GroupBox {
            // TextField(oldKey, text: $oldKey).padding(.horizontal) // Old title should not be text field.
            TextField(editorState.selection, text: $newKey).padding(.horizontal).onSubmit {
                editorState.showingPopover = false
                print("Rename \(editorState.selection) to \(newKey)...")
                print("Document: \(String(describing: document))") // Always nil.  
                document.rename(oldTitle: editorState.selection, newTitle: newKey) // So don't need editor state new title?
            }
        } label: {
            Text("Rename").font(.headline).padding()
        }
    }
}

/*struct RenameView_Previews: PreviewProvider {
    static var previews: some View {
        RenameView()
    }
}*/
