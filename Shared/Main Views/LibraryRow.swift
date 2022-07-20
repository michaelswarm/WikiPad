//
//  LibraryRowView.swift
//  WikiPad
//
//  Created by Michael Swarm on 26/04/22.
//

import SwiftUI

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

struct LibraryRowView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryRow(document: .constant(WikiPadDocument()), title: "title1")
    }
}
