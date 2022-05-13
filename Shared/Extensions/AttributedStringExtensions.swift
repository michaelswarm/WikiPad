//
//  AttributedStringExtensions.swift
//  WikiPad
//
//  Created by Michael Swarm on 30/04/22.
//

//  Used by String extension hypertexts(links) calculated value. 

import Foundation

// IOS 15+, Mac 12+
extension AttributedString {
    
    func allRanges(inRange range: Range<AttributedString.Index>, ofSearchTerm searchTerm: String) -> [Range<AttributedString.Index>] {
        // Case insensitive match
        // As far as I know, no standard function to find all matches. Builds on standard range function.
        var ranges = [Range<AttributedString.Index>]()
        var searchRange = range.lowerBound..<range.upperBound // Variable range (parameter is constant), expressed as bounds and operator. Compare to modification after match below. (The first operand changes.)

        var substring = self[range] // Limit search to range by using substring? Are ranges returned relative to string or substring?
        // self.range(of: searchTerm, options: .caseInsensitive, locale: nil) // No search range available for AttributedString?
        
        while let matchRange = substring.range(of: searchTerm, options: .caseInsensitive, locale: nil) { // No search range available for AttributedString.range(of). Limit search to range by using substring? Are ranges returned relative to string or substring?
            ranges.append(matchRange)
            searchRange = matchRange.upperBound..<searchRange.upperBound // Modify variable search range.
            substring = self[searchRange] // Change substring to limit search range. 
        }
        /*while let matchRange = self.range(of: searchTerm, options: .caseInsensitive, range: searchRange, locale: nil) {
            ranges.append(matchRange)
            searchRange = matchRange.upperBound..<searchRange.upperBound // Modify variable search range.
        }*/

        return ranges
    }
    
    mutating func applyHighlightStyle(toRange range: Range<AttributedString.Index>) {
        var attributes = AttributeContainer()
        attributes.backgroundColor = ParagraphStyle.highlight
        self[range].mergeAttributes(attributes, mergePolicy: .keepNew)
        
        let substring = self[range] // AttributedSubstring. How to get String from AttributedString or AttributedSubstring?
        print("Add yellow background to substring '\(substring)' at range: \(range)")

        // self.addAttribute(NSAttributedString.Key.backgroundColor, value: ParagraphStyle.highlight, range: range)
        // textView.textStorage.setAttributes([NSAttributedString.Key.backgroundColor : ParagraphStyles.highlight], range: range)
        //let string = self.string as NSString
        // let substring = string.substring(with: range)
        // if debug { print("Add yellow background to substring '\(substring)' at range: \(range)") }
    }
    
    mutating func applyLinkStyle(toRange range: Range<AttributedString.Index>, link: String) { // May also need version that takes link: URL?
        
        // Check overwrite should go here, in apply link function.
        // if checkOverwriteShortLink(range: range) { First apply normal style to erase previous link. Then code block below. See actual Hypertexts code. }
        
        // Need to decode before using internal link. Remove with String.removingPercentEncoding!
        let percentEncodedLink = link.stringByAddingPercentEncodingForRFC3986()!
        
        let url = URL(string: link)
        print("URL: \(String(describing: url))") // What is the format of this string URL???
        
        var attributes = AttributeContainer()
        attributes.link = url // Want a plain string here. NSAttributedString would accept a plain string. Swift requires URL, not string.
        
        // Different attributes according to platform. Foundation is common. No common color attribute in Foundation.
        // attributes[AttributeScopes.FoundationAttributes.LinkAttribute.self] = url // Same as above???
        // attributes[AttributeScopes.AppKitAttributes.ForegroundColorAttribute.self] = .red
        // attributes[AttributeScopes.SwiftUIAttributes.ForegroundColorAttribute.self] = .red
        /*
         link as! AttributeScopes.FoundationAttributes.LinkAttribute.Value
         This cast is suggested, although it always fails.
         */
        
        self[range].link = url // Subscript Range<AttributedString.Index> handles range.
        
        // self.mergeAttributes(attributes, mergePolicy: .keepNew) // But what range?
        // self[range].mergeAttributes(attributes, mergePolicy: .keepNew) // Assume .keepNew is default merge policy for above?
        
        // Hypertexts also sets font to body. Do not believe that is necessary.
        // self.addAttribute(NSAttributedString.Key.link, value: link, range: range)
        // Using link from titles preserves original title case. Attempting to use substring from text, which may be either upper or lower case, requires store be case insensitive, which it is not, at least not yet. (It probably should be.)
        // let substring = string.substring(with: range)
        let substring = self[range] // AttributedSubstring. How to get String from AttributedString or AttributedSubstring?
        print("Add link to substring '\(substring)' at range: \(range)")
    }
}
