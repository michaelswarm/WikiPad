//
//  TrailingTopBar.swift
//  WikiPad
//
//  Created by Michael Swarm on 26/04/22.
//

//  Buttons enabled (blue) on IOS. Buttons disabled (light gray) on Mac, until select-hover. 

import SwiftUI

struct Toolbar: View {
    @Binding var document: WikiPadDocument
    @ObservedObject var editorState: HypertextEditorState // Use environment???
    
    // Keep navigation toolbar code clean.
    var body: some View {
        HStack {
            Button(action: { document.add() } ) {
                Image(systemName: "plus") //.font(.system(size: 26.0)) // Font suppressed for Button within ToolbarItem.
            }
            .disabled(!editorState.canAdd()) // Seems to need something dynamic to enable. Otherwise enables on hover.
            .help("Add") // New SwiftUI 3: Mac Tool Tip and Accessibility (Just button?)
            Button(action: { document.delete() } ) {
                Image(systemName: "minus") // .font(.system(size: 26.0)) // Font suppressed for Button within ToolbarItem.
            }
            .disabled(!editorState.canDelete()) // Default seems to be true?
            .help("Delete") // New SwiftUI 3: Mac Tool Tip and Accessibility (Just button?)
        }
        //.border(.blue)
    }
}

/*struct Toolbar_Previews: PreviewProvider {
    static var previews: some View {
        Toolbar(document: .constant(WikiPadDocument()))
    }
}*/
