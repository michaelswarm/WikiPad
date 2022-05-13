//
//  NSMutableAttributedStringExtensions.swift
//  TextLibraryProto
//
//  Created by Michael Swarm on 8/22/20.
//

//
//  NSMutableAttributedStringExtensions.swift
//  Write > TextLibraryProto
//
//  Created by Michael Swarm on 4/27/19.
//  Copyright © 2019 Michael Swarm. All rights reserved.
//

import Foundation
//import AppKit or Cocoa?
/*#if os(OSX)
import AppKit // Needed for NSColor. (Should this be in ParagraphStyle? Move all colors into ParagraphStyle, which handles conditional build between OSX and IOS.)
#endif
#if os(iOS)
import UIKit // Uses UIColor.
#endif*/

// The current extension depends on ParagraphStyles for highlight and no highlight. But does not otherwise use paragraph styles or fonts.

extension NSMutableAttributedString {
    var debug: Bool { false }
    
    // Dependency: Uses proof of concept ParagraphStyle(s) from AttributeFixer.swift.
    // Uses NSAttributedString, NSString and NSRange.
    // Might make more sense as NSAttributedString or NSTextStorage extensions?
    
    // Might want to use these functions in the VC, for example in find-replace???
    // Perhaps text storage extension?
    func applyBodyStyle(toRange range: NSRange) {
        // Should body style include both body font and normal background color?
        // Should body style be set, not added, as typical use is unset previous and set current attributes?
        // self.addAttribute(NSAttributedString.Key.font, value: ParagraphStyle.body, range: range)
        self.setAttributes([NSAttributedString.Key.font : ParagraphStyle.body, NSAttributedString.Key.foregroundColor : ParagraphStyle.text], range: range) // Hypertexts used default attributes = [font : body, forgroundColor : NSColor.textColor] // Added forground color = text color for MacOS Mojave (10.15) Dark Mode.
        if debug { print("Set body style at range: \(range)") }
    }

    // May want paragraph style functions to NOT apply to newline. This might help new line start out at reasonable font. Could check substring for final character, and if newline reduce range?
    func applyHighlightStyle(toRange range: NSRange) {
        // Replace NSAttributedStringKey.font with NSAttributedString.Key.font.
        self.addAttribute(NSAttributedString.Key.backgroundColor, value: ParagraphStyle.highlight, range: range)
        // textView.textStorage.setAttributes([NSAttributedString.Key.backgroundColor : ParagraphStyles.highlight], range: range)
        let string = self.string as NSString
        let substring = string.substring(with: range)
        if debug { print("Add yellow background to substring '\(substring)' at range: \(range)") }
    }
    
    func applyNormalStyle(toRange range: NSRange) {
        // Changes background color. Can be used to unset highlight. Not same as body font.
        self.addAttribute(NSAttributedString.Key.backgroundColor, value: ParagraphStyle.normal, range: range)
        if debug { print("Set normal style at range: \(range)") }
    }
    
    func applyLinkStyleCheckOverwrite(toRange range: NSRange, link: String) {
        // Assumes total overlap. May not handle case of partial overlap?
        if checkOverwriteShortLink(range: range) {
            applyLinkStyle(toRange: range, link: link)
        }
    }
    
    func applyLinkStyle(toRange range: NSRange, link: String) { // May also need version that takes link: URL?
        
        // Check overwrite should go here, in apply link function.
        // if checkOverwriteShortLink(range: range) { First apply normal style to erase previous link. Then code block below. See actual Hypertexts code. }
        
        // Need to decode before using internal link. Remove with String.removingPercentEncoding!
        let percentEncodedLink = link.stringByAddingPercentEncodingForRFC3986()!
        
        // Hypertexts also sets font to body. Do not believe that is necessary.
        self.addAttribute(NSAttributedString.Key.link, value: link, range: range)
        // Using link from titles preserves original title case. Attempting to use substring from text, which may be either upper or lower case, requires store be case insensitive, which it is not, at least not yet. (It probably should be.)
        // Link value parameter should be URL or NSString or nil.
        let string = self.string as NSString
        let substring = string.substring(with: range)
        // let linkString = String(substring)
        if debug { print("Add link to substring '\(substring)' at range: \(range)") }
    }
    
    func checkOverwriteShortLink(range: NSRange) -> Bool {
        // From Hypertexts. Check for existing link attribute, for case of overlapping link.
        // Do not overwrite a longer link with shorter link.
        var overwrite = true // Default is write a link, for cases of either no existing link, or existing link is shorter.
        
        let newLinkAttributedString = self.attributedSubstring(from: range)
        if let linkAttribute = newLinkAttributedString.attribute(NSAttributedString.Key.link, at: 0, effectiveRange: nil) {
            let existingLinkString = linkAttribute as! String
            if debug { print("New Link: \(newLinkAttributedString.string), Existing Link: \(existingLinkString)") } // Developer test.
            if newLinkAttributedString.string.count < existingLinkString.count {
                overwrite = false
            }
        }
        
        return overwrite
    }
    
    func checkSmartLinks(range: NSRange) {
        // let input = "This is a test with the URL https://www.hackingwithswift.com to be detected."
        let input = string
        
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: input, options: [], range: range)
        
        for match in matches {
            guard let range = Range(match.range, in: input) else { continue }
            let url = input[range]
            // print(url)
            self.setAttributes([NSAttributedString.Key.font : ParagraphStyle.body, NSAttributedString.Key.link : url], range: match.range)
        }
    }

    func processEdit(editedRange: NSRange, keywords: [String]) {
        // Same as below, but where keywords is parameter. (Probably eliminate version below?)
        // Change applyHighlightStyle to applyLinkStyle.
        let string: NSString = self.string as NSString
        let linesEditRange = string.lineRange(for: editedRange) // Eliminates the entire extended edited range function. Needs to handle multiple line ranges, which may occur for edit paste. Uses NSString line range for range. Results line or lines containing the changed range, including termination characters.
        
        var extendedRange = NSUnionRange(editedRange, string.lineRange(for: NSMakeRange(editedRange.location, 0))) // The changed range is typically just a single typed character. It may also be zero length in case of backspace, or multiple characters in case of paste. The extended range is the entire line or paragraph in which the change occurs.

        if debug { print("Lines Edit Range: \(linesEditRange)") } // Uses NSString.lineRange for editedRange, not just location.
        if debug { print("Extended Range: \(extendedRange)") } // Uses NSString.lineRange for location.
        assert(linesEditRange == extendedRange)
        
        self.applyBodyStyle(toRange: linesEditRange) // First, normalize the extended range, not just the changed range. This will return style to normal before any highlight. Edits within a match, which may be word or phrase, may invalidate the match. (Highlights need to change background color to normal. Links need to change font to body.)
        
        // Then find matches and apply highlight to matches, within the extended range.
        for keyword in keywords {

            let matches = string.allRanges(inRange: linesEditRange, ofSearchTerm: keyword as NSString) // Test for simple string match before complex regex match. Optimization for majority of negative cases.
            if !matches.isEmpty {
                // FEATURE: WHOLE WORD MATCH
                let pattern = NSString(string: "\\b\(keyword)\\b") // Regex whole word pattern
                let matches = string.allRanges(inRange: linesEditRange, ofSearchPattern: pattern)
                
                // let matches = string.allRanges(inRange: linesEditRange, ofSearchTerm: keyword as NSString) // Then find matches and apply highlight to matches, within the extended range.
                matches.forEach { self.applyLinkStyle(toRange: $0, link: keyword) } // Use either for-in loop or forEach. For-in loop has clear names. No $magic.
                /* for range in matches {
                    applyLinkStyle(toRange: range)
                } */
            }
        }
        checkSmartLinks(range: linesEditRange)
    }

    func processEdit(editedRange: NSRange) {
        
        let keywords = ["if", "else"] // Try simple keyword highlight.
        let string: NSString = self.string as NSString
        let linesEditRange = string.lineRange(for: editedRange) // Eliminates the entire extended edited range function. Needs to handle multiple line ranges, which may occur for edit paste. Uses NSString line range for range. Results line or lines containing the changed range, including termination characters.
        
        var extendedRange = NSUnionRange(editedRange, string.lineRange(for: NSMakeRange(editedRange.location, 0)))
        // The changed range is typically just a single typed character. It may also be zero length in case of backspace, or multiple characters in case of paste. The extended range is the entire line or paragraph in which the change occurs.
        
        self.applyNormalStyle(toRange: extendedRange) // First, normalize the extended range, not just the changed range. This will return style to normal before any highlight. Edits within a match, which may be word or phrase, may invalidate the match.
        
        for keyword in keywords {
            let matches = string.allRanges(inRange: extendedRange, ofSearchTerm: keyword as NSString) // Then find matches and apply highlight to matches, within the extended range.
            matches.forEach { self.applyHighlightStyle(toRange: $0) } // Use either for-in loop or forEach. For-in loop has clear names. No $magic.
            /* for range in matches {
                applyHighlightStyle(toRange: range)
            } */
        }
    }

}
