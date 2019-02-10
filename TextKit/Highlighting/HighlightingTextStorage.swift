//
//  HighlightingTextStorage.swift
//  TextKit
//
//  Created by Guang Lei  on 2019/2/3.
//  Copyright © 2019 Guang Lei . All rights reserved.
//

import UIKit

/*
 
 Subclassing Notes
 The NSTextStorage class implements change management (via the beginEditing() and endEditing() methods), verification of attributes, delegate handling, and layout management notification. The one aspect it does not implement is managing the actual attributed string storage, which subclasses manage by overriding the two NSAttributedString primitives:
 
 string
 
 attributes(at:effectiveRange:)
 
 Subclasses must also override two NSMutableAttributedString primitives:
 
 replaceCharacters(in:with:)
 
 setAttributes(_:range:)
 
 These primitives should perform the change, then call edited(_:range:changeInLength:) to let the parent class know what changes were made.
 
 */

class HighlightingTextStorage: NSTextStorage {
    
    private let backingStore = NSMutableAttributedString()
    
    // MARK: - Reading Text
    
    override var string: String {
        return backingStore.string
    }
    
    override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedString.Key : Any] {
        return backingStore.attributes(at: location, effectiveRange: range)
    }
    
    // MARK - Text Editing
    
    override func replaceCharacters(in range: NSRange, with str: String) {
        beginEditing()
        backingStore.replaceCharacters(in: range, with: str)
        edited(.editedCharacters, range: range, changeInLength: str.count - range.length)
        endEditing()
    }

    override func setAttributes(_ attrs: [NSAttributedString.Key : Any]?, range: NSRange) {
        beginEditing()
        backingStore.setAttributes(attrs, range: range)
        edited(.editedAttributes, range: range, changeInLength: 0)
        endEditing()
    }
    
    override func processEditing() {
        do {
            // Regular expression matching all iWords -- first character i, followed by an uppercase alphabetic character, followed by at least one other character. Matches words like iPod, iPhone, etc.
            let iExpression = try NSRegularExpression(pattern: "i[\\p{Alphabetic}&&\\p{Uppercase}][\\p{Alphabetic}]+", options: [])
            
            // Clear text color of edited range
            let paragraphRange = (string as NSString).paragraphRange(for: editedRange)
            removeAttribute(.foregroundColor, range: paragraphRange)
            
            // Find all iWords in range
            iExpression.enumerateMatches(in: string, options: [], range: paragraphRange) { (result, _, _) in
                guard let result = result else {
                    return
                }
                // Add red highlight color
                addAttribute(.foregroundColor, value: UIColor.red, range: result.range)
            }
        } catch {
            print(error)
        }
        
        // Call super *after* changing the attributes, as it finalizes the attributes and calls the delegate methods.
        super.processEditing()
    }
}
