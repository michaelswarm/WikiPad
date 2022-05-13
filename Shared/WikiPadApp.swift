//
//  WikiPadApp.swift
//  Shared
//
//  Created by Michael Swarm on 22/04/22.
//

import SwiftUI

@main
struct WikiPadApp: App {
    
    var body: some Scene {
        DocumentGroup(newDocument: WikiPadDocument()) { file in
            SplitNavigationView(document: file.$document) 
            // ContentView(document: file.$document)
                .focusedSceneValue(\.document, file.$document) // Scene value equivalent of environment for values?
                .environmentObject(file.document.editorState)
        }
        .commands {
            FileCommands() // Add commands to Scene, not View. Document not available here. Use top level app object that includes editor state? (Still no access to document. Can top level app have optional document? What about multiple documents?)
        }
    }
}
