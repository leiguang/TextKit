//
//  LinkDetectingTextStorage.swift
//  TextKit
//
//  Created by Guang Lei  on 2019/2/3.
//  Copyright © 2019 Guang Lei . All rights reserved.
//

import UIKit

class LinkDetectingTextStorage: NSTextStorage {

    private let backingStore = NSMutableAttributedString()
    
    private var linkDetector: NSDataDetector?
    
    // MARK: - Reading Text
    
    override var string: String {
        return backingStore.string
    }
    
    override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedString.Key : Any] {
        return backingStore.attributes(at: location, effectiveRange: range)
    }
    
    // MARK: - Text Editing
    
    override func replaceCharacters(in range: NSRange, with str: String) {
        // Normal replace
        beginEditing()
        backingStore.replaceCharacters(in: range, with: str)
        edited(.editedCharacters, range: range, changeInLength: str.count - range.length)
        
        //
        if linkDetector == nil {
            do {
                // Regular expression matching all links.
                linkDetector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)   
            } catch {
                print(error)
            }
        }
        
        // Clear text color of edited range
        let paragraphRange = (string as NSString).paragraphRange(for: NSRange(location: range.location, length: str.count))
        removeAttribute(.link, range: paragraphRange)
        removeAttribute(.backgroundColor, range: paragraphRange)
        removeAttribute(.underlineStyle, range: paragraphRange)
        
        // Find all link in range
        linkDetector?.enumerateMatches(in: string, options: [], range: paragraphRange, using: { (result, _, _) in
            guard let url = result?.url, let range = result?.range else {
                return
            }
            // Add red highlight color
            addAttribute(.link, value: url, range: range)
            addAttribute(.backgroundColor, value: UIColor.yellow, range: range)
            addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        })
        
        endEditing()
    }
    
    override func setAttributes(_ attrs: [NSAttributedString.Key : Any]?, range: NSRange) {
        beginEditing()
        backingStore.setAttributes(attrs, range: range)
        edited(.editedAttributes, range: range, changeInLength: 0)
        endEditing()
    }
}
