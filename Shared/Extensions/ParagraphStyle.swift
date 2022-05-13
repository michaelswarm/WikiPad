//
//  ParagraphStyle.swift
//  TextLibraryProto
//
//  Created by Michael Swarm on 8/22/20.
//

//
//  ParagraphStyle.swift
//  Write > TextLibraryProto
//
//  Created by Michael Swarm on 4/27/19.
//  Copyright © 2019 Michael Swarm. All rights reserved.
//

import Foundation

#if os(OSX)
import AppKit
struct ParagraphStyle {
    // How to handle fonts in platform independent way? UIFont vs NSFont? Preprocessor?
    
    // static let body = UIFont.preferredFont(forTextStyle: .body)
    // static let header1 = UIFont.preferredFont(forTextStyle: .title1) // #
    // static let header2 = UIFont.preferredFont(forTextStyle: .title2) // ##
    // static let header3 = UIFont.preferredFont(forTextStyle: .title3) // ###
    
    enum Keys: String {
        case scaleFactor = "ScaleFactor"
        case paragraphStyleChange = "ParagraphStyleChange"
    }
    
    static func postParagraphStyleChangeNotification() {
        let main = DispatchQueue.main
        main.async {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Keys.paragraphStyleChange.rawValue), object: self, userInfo: nil) // Swift 4
        }
    }
    
    var input = 1.0  { // Use same input to scale factor across all fonts.
        didSet { // Set input should change scale factor.
            // Bound scale by min and max. Min 0.5 and Max 3.0.
            // if scale < min then scale = min
            // if scale > max then scale = max
            let scale = clamp(input, minValue: 0.5, maxValue: 2.0) // 6pt is too small to be usable. Maybe on huge panels? 9pt is too small to be usable either. 36pt is huge, perhaps for those nearly blind.
        }
    }
    var scale: Float { // Read only property
        return _scale
    }
    var _scale: Float = 1.0 // Set by input above, which is clamped.

    func clamp<T: Comparable>(_ value: T, minValue: T, maxValue: T) -> T {
        // func clamp(value, minValue, maxValue) -> type
        // let clamped = min(max(value, minValue), maxValue)
        return min(max(value, minValue), maxValue)
    }
    
    static func body(scale: Float) -> NSFont { // Scale here already clamped.
        let size = 18.0 * scale
        let userFontSize = size
        // let userFontSize = 18.0 // app.system.settings.textSize (bump from 16.0)
        let font = NSFont.userFont(ofSize: CGFloat(userFontSize)) // Convert Double(64) to CGFloat(32 or 64)
        assert( font != nil ) // My IOS fonts are not optional, but my OSX fonts are optional. When does NSFont.userFont(ofSize) return nil? Not trying to use any user installed fonts.
        return font!
    }
    
    static let body: NSFont = {
        // Bound scale by min and max. Min 0.5 and Max 3.0.
        // if scale < min then scale = min
        // if scale > max then scale = max
        // func clamp(value, minValue, maxValue) -> type
        // let clamped = min(max(value, minValue), maxValue)
        func clamp<T: Comparable>(_ value: T, minValue: T, maxValue: T) -> T {
            return min(max(value, minValue), maxValue)
        }
        let input = 1.0 // Input percent divide by 100. (How to validate input?)
        let scale = clamp(input, minValue: 0.5, maxValue: 2.0) // 6pt is too small to be usable. Maybe on huge panels? 9pt is too small to be usable either. 36pt is huge, perhaps for those nearly blind.
        let size = 18.0 * scale
        let userFontSize = size
        // let userFontSize = 18.0 // app.system.settings.textSize (bump from 16.0)
        let font = NSFont.userFont(ofSize: CGFloat(userFontSize)) // Convert Double(64) to CGFloat(32 or 64)
        assert( font != nil ) // My IOS fonts are not optional, but my OSX fonts are optional. When does NSFont.userFont(ofSize) return nil? Not trying to use any user installed fonts.
        return font!
    }()
    static let header1: NSFont = {
        func clamp<T: Comparable>(_ value: T, minValue: T, maxValue: T) -> T {
            return min(max(value, minValue), maxValue)
        }
        let input = 1.0 // Input percent divide by 100. (How to validate input?)
        let scale = clamp(input, minValue: 0.5, maxValue: 2.0) // 6pt is too small to be usable. Maybe on huge panels? 9pt is too small to be usable either. 36pt is huge, perhaps for those nearly blind.
        let size = 28.0 * scale
        let userFontSize = size
        let font = NSFont.userFont(ofSize: CGFloat(userFontSize)) // Convert Double(64) to CGFloat(32 or 64)
        assert( font != nil ) // My IOS fonts are not optional, but my OSX fonts are optional. When does NSFont.userFont(ofSize) return nil? Not trying to use any user installed fonts.
        return font!
    }()
    
    // Character Styles
    static let highlight = NSColor.yellow
    static let normal = NSColor.white
    static let text = NSColor.textColor // Necessary for Mojave Dark Mode. Should be default. Body text color. (There is also NSColor.headerTextColor.) Any use of this color will not be portable. (If only used within OSX MVC, then why bother to place here, except to notice that it is not portable.)
}

#elseif os(iOS)
import UIKit
struct ParagraphStyle {
    // How to handle fonts in platform independent way? UIFont vs NSFont? Preprocessor?
    static let body = UIFont.preferredFont(forTextStyle: .body)
    static let header1 = UIFont.preferredFont(forTextStyle: .title1) // #
    static let header2 = UIFont.preferredFont(forTextStyle: .title2) // ##
    static let header3 = UIFont.preferredFont(forTextStyle: .title3) // ###
    
    // Character Styles
    static let highlight = UIColor.yellow
    // static let text = UIColor.textColor // No such thing. Not used by IOS apps. But also don't need to change for Dark Mode. Any use of this color will not be portable. IOS 13+ appears to use UIColor.label.
    
    // Can not use if #available for declarations.
    // Change to backgroundColor??? (Similar to IOS system Background Color.)
    static var normal: UIColor { // Used by ParagraphStyle for text background color.
        if #available(iOS 13, *) { // IOS 13+ Dark Mode
            return UIColor.systemBackground
        } else {
            return UIColor.white
        }
    }
    // Change to textColor??? (Match OSX text Color.)
    static var text: UIColor { // Used by ParagraphStyle for text foreground color.
        if #available(iOS 13, *) { // IOS 13+ Dark Mode
            return UIColor.label
        } else {
            return UIColor.black
        }
    }
}

#endif
