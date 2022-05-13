//
//  SidebarView.swift
//  WikiPad
//
//  Created by Michael Swarm on 26/04/22.
//

import SwiftUI

struct SidebarList: View {
    @Binding var document: WikiPadDocument
    
    var data: [String] {
        Array(document.store.titlesSortedByModified()) // Sort recent first. 
        //Array(document.store.textDictionary.keys)
    }

    var body: some View {
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
}

struct SidebarList_Previews: PreviewProvider {
    static var previews: some View {
        SidebarList(document: .constant(WikiPadDocument()))
    }
}
