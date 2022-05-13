//
//  FocusedValuesExtension.swift
//  PlainText
//
//  Created by Michael Swarm on 01/03/22.
//

import Foundation
import SwiftUI

// https://developer.apple.com/documentation/swiftui/text/focusedscenevalue/
// https://lostmoa.com/blog/ProvidingTheCurrentDocumentToMenuCommands/

struct DocumentKey: FocusedValueKey {
    typealias Value = Binding<WikiPadDocument>
}
struct FilterActionKey: FocusedValueKey {
    typealias Value = () -> Void
}
    
extension FocusedValues {
    var document: Binding<WikiPadDocument>? {
        get { self[DocumentKey.self] }
        set { self[DocumentKey.self] = newValue }
    }
    var filterAction: (() -> Void)? {
        get { self[FilterActionKey.self] }
        set { self[FilterActionKey.self] = newValue }
    }
}
