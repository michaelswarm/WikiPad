//
//  NavigationBar.swift
//  WikiPad
//
//  Created by Michael Swarm on 01/05/22.
//

import SwiftUI

struct NavigationBar: View {
    @Binding var document: WikiPadDocument
    @ObservedObject var editorState: HypertextEditorState // Use environment???
    
    // Keep navigation toolbar code clean.
    var body: some View {
        HStack {
            Button(action: { document.back() } ) {
                Image(systemName: "chevron.left") //.font(.system(size: 26.0)) // chevron.backward is available, and localized.
            }
            .disabled(!editorState.browser.canBack()) // Disable if CAN NOT back.
            .help("Back") // New SwiftUI 3: Mac Tool Tip and Accessibility (Just button?)
            Button(action: { document.forward() } ) {
                Image(systemName: "chevron.right") //.font(.system(size: 26.0)) // chevron.forward is available, and localized.
            }
            .disabled(!editorState.browser.canForward()) // Disable if CAN NOT forward.
            .help("Forward") // New SwiftUI 3: Mac Tool Tip and Accessibility (Just button?)
        }
        //.border(.blue)
    }
}

/*struct NavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        NavigationBar(document: .constant(WikiPadDocument()))
    }
}*/
