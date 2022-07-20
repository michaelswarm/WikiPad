//
//  SidebarList.swift
//  WikiPad
//
//  Created by Michael Swarm on 26/04/22.
//

import SwiftUI

struct SidebarList: View {
    @Binding var document: WikiPadDocument
    
    // Calculated Data: Mini view model. Transforms data from model to view model structure. Move filter into calculated data.
    var data: [String] {
        document.store.titlesSortedByModified().filter{ $0.lowercased().hasPrefix(searchString.lowercased()) }
        //document.store.titlesSortedByModified() // Sort recent first.
        //Array(document.store.textDictionary.keys) // Mini view-model transforms set to array.
    }
    @State var searchString = ""

    var body: some View {
        List {
            // Section(header: Text("Titles")) { // Arrow to expand and collapse.
                ForEach(data, id: \.self) { title in
                    LibraryRow(document: $document, title: title)
                }
            // }
            /*
            Divider()
            Text(searchString)
            
            Button("Add") {
                document.add()
            }
            Button("Delete") {
                document.delete()
            }
            */
        }
        .listStyle(.sidebar) // MacOS 11+
        // Bug (IOS): Sidebar search field initially not visible until swipe down. Then occupies the entire screen width! Once displayed can not hide. Has cancel. Which erases search text, but does not hide. Not impressed by searchable modifier implementation.
        .searchable(text: $searchString, placement: .sidebar, prompt: Text("")) // Sidebar placement! Does not display cancel option.
        // prompt: nil displays default "Search" text. Empty "" is visually quiet. "Title" is visually noisy.
        
    }
}

struct SidebarList_Previews: PreviewProvider {
    static var previews: some View {
        SidebarList(document: .constant(WikiPadDocument()))
    }
}
