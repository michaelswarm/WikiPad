//
//  NSStringExtensions.swift
//  TextLibraryProto
//
//  Created by Michael Swarm on 8/22/20.
//

//
//  NSStringExtensions.swift
//  Write
//
//  Created by Michael Swarm on 4/27/19.
//  Copyright © 2019 Michael Swarm. All rights reserved.
//

import Foundation

// Used by Document MVC.
extension NSString {
    func allRanges(inRange range: NSRange, ofSearchTerm searchTerm: NSString) -> [NSRange] {
        // Case insensitive match
        // As far as I know, no standard function to find all matches. Builds on standard range function.
        var ranges = [NSRange]()
        var searchRange: NSRange = range // Variable range (parameter is constant), expressed as bounds and operator. Compare to modification after match below. (The first operand changes.)
        
        var matchRange = self.range(of: searchTerm as String, options: .caseInsensitive, range: searchRange, locale: nil) // Preliminary to loop.
        
        while matchRange.location != NSNotFound { // Swift String range returns an optional. The NSString range returns a NSRange. How to determine no match? NSString range of returns {NSNotFound, 0} if not found or string empty.
            ranges.append(matchRange)
            
            let location = matchRange.location + matchRange.length // matchRange.upperBound
            let length = searchRange.upperBound - matchRange.upperBound // Is this correct? Off by 1?
            searchRange = NSMakeRange(location, length) // How to calculate the new search range? Unlike Swift Range, NSRange does not use constant upper bound, but variable length.
            
            matchRange = self.range(of: searchTerm as String, options: .caseInsensitive, range: searchRange, locale: nil)  // Prelimary to next iteration.
        }
        
        return ranges
    }

    func allRanges(inRange range: NSRange, ofSearchPattern searchPattern: NSString) -> [NSRange] {
        // Case insensitive match
        // As far as I know, no standard function to find all matches. Builds on standard range function.
        var ranges = [NSRange]()
        var searchRange: NSRange = range // Variable range (parameter is constant), expressed as bounds and operator. Compare to modification after match below. (The first operand changes.)
        
        var matchRange = self.range(of: searchPattern as String, options: [.regularExpression, .caseInsensitive], range: searchRange, locale: nil) // Preliminary to loop.
        
        while matchRange.location != NSNotFound { // Swift String range returns an optional. The NSString range returns a NSRange. How to determine no match? NSString range of returns {NSNotFound, 0} if not found or string empty.
            ranges.append(matchRange)
            
            let location = matchRange.location + matchRange.length // matchRange.upperBound
            let length = searchRange.upperBound - matchRange.upperBound // Is this correct? Off by 1?
            searchRange = NSMakeRange(location, length) // How to calculate the new search range? Unlike Swift Range, NSRange does not use constant upper bound, but variable length.
            
            matchRange = self.range(of: searchPattern as String, options: [.regularExpression, .caseInsensitive], range: searchRange, locale: nil) // Prelimary to next iteration.
        }
        
        return ranges
        
        // Use of regular match to filter out negatives before whole word match should go here. Or be specialized version of function that calls all ranges(in range: of search pattern:) after all ranges(in range: of search term)???
    }

}
