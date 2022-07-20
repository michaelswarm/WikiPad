//
//  Titlebar.swift
//  WikiPad
//
//  Created by Michael Swarm on 26/04/22.
//

//  Bug: TextField does not update if selection after edit-rename. Why???

import SwiftUI

struct Titlebar: View {
    @Binding var document: WikiPadDocument // Can use focused scene state???
    @ObservedObject var editorState: HypertextEditorState // Use environment???
    // @EnvironmentObject var editorState: HypertextEditorState
    // @Binding var title: String
    @State var newKey: String = "" // Binding not needed.

    @State var isEdit = false
    @FocusState var isFocused: Bool // IOS 15+

    var body: some View {
        // TextField("", text: $title)
        ZStack {
            // font .headline or .largeTitle
            /*Text(editorState.selection).font(.title) // Font should actually be slightly larger. (Unedited document title is larger than this.)
                .onTapGesture {
                    isEdit.toggle() // How to escape from TextField rename???
                    // Changes opacity. Does not select-focus. Bug: Requires second selection to focus.
                }
                .frame(minWidth: 200, alignment: .leading)
                //.border(.red)
                .opacity(isEdit ? 0.0 : 1.0)*/
            
            /*TextField(editorState.selection, text: $newKey) {
                editingChanged in
                if editingChanged {
                    print("Focused...")
                    // How to detect submit???
                } else {
                    print("Loose focus...")
                    isEdit.toggle()
                }
                // This sometimes works, sometimes does not.
            }*/
            TextField(text: $newKey) {
                // Prompt
                // Prompt is light gray or opaque.
                Text(editorState.selection) //.font(.largeTitle) // Font within text field supressed on Mac. (Does function on IOS.)
            }
            .textFieldStyle(.plain) // .automatic, .plain, .roundedBorder, .squareBorder
            .onSubmit {
                isEdit.toggle()
                print("Rename \(editorState.selection) to \(newKey)...")
                // print("Document: \(String(describing: document))") // Always nil. (Not nil here. Prints the entire store!)
                document.rename(oldTitle: editorState.selection, newTitle: newKey) // So don't need editor state new title?
                newKey = "" // Bug fix: Return newKey to empty, so prompt show again.
            }
            .frame(minWidth: 200) // TextField default alignment leading
            //.border(.blue)
            //.opacity(isEdit ? 1.0 : 0.0)

            
            /*TextField(editorState.selection, text: $newKey)
                .font(.title3)
                .focused($isFocused)
                .onChange(of: isFocused) { newValue in
                    print("Focus \(newValue)...") // This never prints.
                    // isFocused = newValue
                    isEdit = false // This is not working!!!
                }
                .onSubmit {
                isEdit.toggle()
                print("Rename \(editorState.selection) to \(newKey)...")
                // print("Document: \(String(describing: document))") // Always nil. (Not nil here. Prints the entire store!)
                document.rename(oldTitle: editorState.selection, newTitle: newKey) // So don't need editor state new title?
            }*/
            //.border(.blue)
            //.opacity(isEdit ? 1.0 : 0.0)
        }
    }
}

struct Titlebar_Previews: PreviewProvider {
    static var previews: some View {
        Titlebar(document: .constant(WikiPadDocument()), editorState: HypertextEditorState(store: TextStoreMemory()))
    }
}
