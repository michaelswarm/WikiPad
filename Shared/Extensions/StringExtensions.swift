//
//  StringExtensions.swift
//  TextLibraryProto
//
//  Created by Michael Swarm on 7/18/20.
//
//  Jan 2021 added var words: [String]. Both StringExtensions and NLStringExtensions provide lines and words.

import Foundation

extension String {
    func stringByAddingPercentEncodingForRFC3986() -> String? {
        let unreserved = "-.~/?"
        let alphaAndUnreserved = NSMutableCharacterSet.alphanumeric()
        alphaAndUnreserved.addCharacters(in: unreserved)
        let allowed = alphaAndUnreserved as CharacterSet
        return self.addingPercentEncoding(withAllowedCharacters: allowed)!
    }
    // Remove with String.removingPercentEncoding! // String?
    
    var terms: [String] { // Added for folder project title index.
        let separators = CharacterSet.whitespacesAndNewlines // Naive separation. Also see words and nlpWords.
        let components = self.components(separatedBy: separators)
        let terms = components.filter { !$0.isEmpty }
        return terms
    }
    var lines: [String] { return self.components(separatedBy: .newlines) } // Remove the newlines. Check NLP version.
    var words: [String] {
        let separators = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters).union(.symbols).union(.decimalDigits) // Includes symbols (+-*/=) as words. NLP does not include symbols (+-*/=) as words.
        let components = self.components(separatedBy: separators)
        let words = components.filter { !$0.isEmpty }
        return words
    }
    var sections: [String] {
        // let separator = "\n\n" // or "\n\n\n" ???
        // let sections = self.components(separatedBy: separator)
        // return self.components(separatedBy: separator)
        // let noEmptySections = sections.filter { !$0.isEmpty }
        // Filter empty sections can still leaves non empty sections with odd leading returns.
        // Separate by pattern, 2 or more returns, not characters or string? Use custom regex split String extension, below.
        // return noEmptySections
        
        // Using regex repetition avoids empty sections. Leaves single returns within sections and at end of last section.
        let splits = self.split(usingRegex: "\n{2,}") // {2,} is explicit repetition 2 or more. // BUG: CRASH WITHIN SPLIT(USING REGEX). What text title causes crash so I can analyze and understand what is happening here?
        // return splits

        // Still possible to have empty sections (only end?).
        let nonEmptySections = splits.filter { !$0.isEmpty }
        return nonEmptySections
    }
    
    func allRanges(inRange range: Range<String.Index>, ofSearchTerm searchTerm: String) -> [Range<String.Index>] {
        // Case insensitive match
        // As far as I know, no standard function to find all matches. Builds on standard range function.
        var ranges = [Range<String.Index>]()
        var searchRange = range.lowerBound..<range.upperBound // Variable range (parameter is constant), expressed as bounds and operator. Compare to modification after match below. (The first operand changes.)

        while let matchRange = self.range(of: searchTerm, options: .caseInsensitive, range: searchRange, locale: nil) {
            ranges.append(matchRange)
            searchRange = matchRange.upperBound..<searchRange.upperBound // Modify variable search range.
        }

        return ranges
    }
    
    func allRanges(inRange range: Range<String.Index>, ofSearchPattern searchPattern: String) -> [Range<String.Index>] {
        // Case insensitive pattern match
        // As far as I know, no standard function to find all matches. Builds on standard range function.
        var ranges = [Range<String.Index>]()
        var searchRange = range.lowerBound..<range.upperBound // Variable range (parameter is constant), expressed as bounds and operator. Compare to modification after match below. (The first operand changes.)
        
        while let matchRange = self.range(of: searchPattern, options: [.regularExpression, .caseInsensitive], range: searchRange, locale: nil) {
            ranges.append(matchRange)
            searchRange = matchRange.upperBound..<searchRange.upperBound // Modify variable search range.
        }
        
        return ranges
    }
    
    // From Stack Overflow: https://stackoverflow.com/questions/57215919/how-to-get-components-separated-by-regular-expression-but-also-with-separators
    // Does not include separators in components.
    func split(usingRegex pattern: String) -> [String] {
        let regex = try! NSRegularExpression(pattern: pattern)
        let matches = regex.matches(in: self, range: NSRange(0..<utf16.count))
        let ranges = [startIndex..<startIndex] + matches.map{Range($0.range, in: self)!} + [endIndex..<endIndex] // BUG: CRASH UNWRAPPING OPTIONAL
        return (0...matches.count).map {String(self[ranges[$0].upperBound..<ranges[$0+1].lowerBound])}
    }
    
    // Experiment: Could use with SwiftUI Text? Move hypertext out of editor and into String and AttributedString extensions. (*TextView NSTextStorage is just NSMutableAttributedString, and process edit handled as NSMutableString extension.) Could calculate non-editable hypertext view from plain text edits? 
    func hypertext() -> AttributedString {
        // Experiment here. Logic based on NSMutableAttributedString extension processEdit().
        /*
         Assumptions
         1. Entire string range.
         2. Calculated value with no previous attribute state. (Process edit assumes a mutable attributed string, which can have previous attributes.)
         3. Fixed keywords.
         */
        var attributed = AttributedString(self)
        
        let keywords = ["if", "else"] // Try simple keyword highlight.
        let range: Range<String.Index> = self.startIndex..<self.endIndex
        let attributedRange: Range<AttributedString.Index> = attributed.startIndex..<attributed.endIndex
        
        for keyword in keywords {
            // let matches = self.allRanges(inRange: range, ofSearchTerm: keyword) // Then find matches and apply highlight to matches, within the extended range.
            let matches = attributed.allRanges(inRange: attributedRange, ofSearchTerm: keyword)
            print("Possible matches: \(matches)")

            // applyHighlightStyle requires Range<AttributedString.Index>, not Range<String.Index>. 
            
            // matches.forEach { self.applyHighlightStyle(toRange: $0) } // Use either for-in loop or forEach. For-in loop has clear names. No $magic.
            matches.forEach {
                print("Match found: \($0)") // Do not get this far.
                attributed.applyHighlightStyle(toRange: $0)
                
            } // Use either for-in loop or forEach. For-in loop has clear names. No $magic.
            /* for range in matches {
                applyHighlightStyle(toRange: range)
            } */
        }
        return attributed
        
        
        /* Above hypertext() based on processEdit() below.
        func processEdit(editedRange: NSRange) {
            
            let keywords = ["if", "else"] // Try simple keyword highlight.
            let string: NSString = self.string as NSString
            let linesEditRange = string.lineRange(for: editedRange) // Eliminates the entire extended edited range function. Needs to handle multiple line ranges, which may occur for edit paste. Uses NSString line range for range. Results line or lines containing the changed range, including termination characters.
            
            var extendedRange = NSUnionRange(editedRange, string.lineRange(for: NSMakeRange(editedRange.location, 0)))
            // The changed range is typically just a single typed character. It may also be zero length in case of backspace, or multiple characters in case of paste. The extended range is the entire line or paragraph in which the change occurs.
            
            // self.applyNormalStyle(toRange: extendedRange) // First, normalize the extended range, not just the changed range. This will return style to normal before any highlight. Edits within a match, which may be word or phrase, may invalidate the match.
            
            for keyword in keywords {
                let matches = string.allRanges(inRange: extendedRange, ofSearchTerm: keyword as NSString) // Then find matches and apply highlight to matches, within the extended range.
                matches.forEach { self.applyHighlightStyle(toRange: $0) } // Use either for-in loop or forEach. For-in loop has clear names. No $magic.
                /* for range in matches {
                    applyHighlightStyle(toRange: range)
                } */
            }
        }
        */
    }
}
