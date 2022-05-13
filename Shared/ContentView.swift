//
//  ContentView.swift
//  Shared
//
//  Created by Michael Swarm on 22/04/22.
//
/*
import SwiftUI

struct ContentView: View {
    @Binding var document: WikiPadDocument
    
    var data: [String] {
        Array(document.store.textDictionary.keys)
    }
    
    // Keep navigation toolbar code clean.
    var trailingTopBar: some View {
        HStack {
            Button(action: { document.add() } ) {
                Image(systemName: "plus").font(.system(size: 26.0))
            }
            .help("Add") // New SwiftUI 3: Mac Tool Tip and Accessibility (Just button?)
            Button(action: { document.delete() } ) {
                Image(systemName: "minus").font(.system(size: 26.0))
            }
            .help("Delete") // New SwiftUI 3: Mac Tool Tip and Accessibility (Just button?)
        }
    }
    
    var sidebar: some View {
        List {
            Section(header: Text("Titles")) { // Arrow to expand and collapse.
                ForEach(data, id: \.self) { title in
                    LibraryRow(document: $document, title: title)
                }
            }
            Divider()
            Button("Add") {
                document.add()
            }
            Button("Delete") {
                document.delete()
            }
        }
        .listStyle(.sidebar) // MacOS 11+
    }

    var body: some View {
        NavigationView {
            SidebarList(document: $document)
            // Issue: How to bind to dictionary value???
            HypertextEditor(text: Binding<String>(
                get: { self.document.store.textDictionary[self.document.editorState.selection]?.content ?? "No content" },
                set: { self.document.store.textDictionary[self.document.editorState.selection]?.content = $0 }
            ), libraryState: document.editorState)

            /*TextEditor(text: Binding<String>(
                get: { self.document.library.textStore[self.document.library.selection]?.content ?? "No content" },
                set: { self.document.library.textStore[self.document.library.selection]?.content = $0 }
            ))*/
        }
        
        // 'navigationBarLeading' is unavailable in macOS
        // SwiftUI v3 supports platform conditional modifiers for postfix member expressions and modifiers.
        #if os(iOS)
        .toolbar {
            ToolbarItem(placement: side == .left ? .navigationBarLeading : .navigationBarTrailing ) {
                trailingTopBar
            }
        }
        #endif
        #if os(OSX)
        // Toolbar MacOS Monterey very tall!
        .toolbar {
            ToolbarItem(placement: .automatic) { // .automatic (Mac right), .primaryAction (Mac right), .principal (Mac middle), .navigation (Mac left)
                trailingTopBar
            }
        }
        #endif
    }
}


struct LibraryRow: View {
    @Binding var document: WikiPadDocument
    var title: String
    
    var body: some View {
        HStack { // TitleRow
            Text(title)
            Spacer() // Space becomes part of tappable area.
        }
            .contentShape(Rectangle())
            .onTapGesture {
                document.editorState.update(store: document.store, selection: title) // This does not trigger update, even though binding to struct. Why???
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(WikiPadDocument()))
    }
}
*/
