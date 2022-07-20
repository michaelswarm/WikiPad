//
//  TextCanvas.swift
//  WikiPad
//
//  Created by Michael Swarm on 27/04/22.
//

import SwiftUI

struct TextCanvas: View {
    @Binding var document: WikiPadDocument
    @EnvironmentObject var editorState: HypertextEditorState
    
    // @ObservedObject var editorState: HypertextEditorState
    // Constant reference will not change. Thus change of anything in editor state will not update.
    // Editor state must be passed separately.
    // Values and references must be passed separately.
    // For a value that contains a reference, the reference must be passed and observed separately. 

    
    // Calculated bindings as calculated vars. (Must be a better way???)
    var bindingText: Binding<String> { // textBinding???
        Binding<String>(
            get: { document.store.textDictionary[editorState.selection]?.content ?? "No content" },
            set: { document.store.textDictionary[editorState.selection]?.content = $0 }
        )
    }
    
    var body: some View {
        VStack {
            /*HStack { // Move title to top bar (unified tool-title bar).
                Text(editorState.selection) // Compare selection display here with titlebar selection. 
                Spacer()
            }*/
            HypertextEditor(text: bindingText, libraryState: editorState)
            /*Text(editorState.selection)
            Divider()
            ScrollView(.horizontal) {
                HStack {
                    ForEach(editorState.links, id: \.self) { link in
                        Text(link).lineLimit(1)
                    }
                }
            }*/
            /*ScrollView {
                Text((document.store.textDictionary[editorState.selection]?.content ?? "No content").hypertext())
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                // .border(.blue)
                    .padding(4) // Match editor margin, which appears to be half the default padding.
            }*/
        }
    }
}

/*struct TextCanvas_Previews: PreviewProvider {
    static var previews: some View {
        TextCanvas()
    }
}*/
