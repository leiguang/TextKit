//
//  BindingManager.swift
//  TextKit
//
//  Created by Guang Lei  on 2019/2/13.
//  Copyright © 2019 Guang Lei . All rights reserved.
//

import UIKit

/*
 - Note:
 The text may contain multi-byte encoded character. eg: "emoji 😃, its text.count = 1, but attributeText.length = 2".
 So remember using attributedText.length to calculate range and length in BindingManager.
 */

protocol BindingManagerDelegate: class {
    var typingAttributes: [NSAttributedString.Key: Any] { get }
    func bindingObjectDeleted(object: BindingProtocol)
    func textDidChange(_ textView: UITextView)
}

class BindingManager: NSObject {
    
    let bindingKey = NSAttributedString.Key("textBinding")
    
    unowned var textView: BindingTextView

    weak var delegate: BindingManagerDelegate?
    
    private var bindingBoxs: [BindingBox<BindingProtocol>] = [] {
        didSet {
            print("bindingObjects:", bindingBoxs.map { $0.value.bindingText + ":" + String($0.uuid.uuidString.prefix(6)) })
        }
    }
    
    var bindingObjects: [BindingProtocol] {
        return bindingBoxs.map { $0.value }
    }
    
    init(textView: BindingTextView) {
        self.textView = textView
    }
    
    func addBindingObject<T: BindingProtocol>(_ object: T, in range: NSRange) {
        guard let attributedText = textView.attributedText, range.location != NSNotFound, range.location + range.length <= attributedText.length else {
            return
        }
        removeBindingObjects(in: range)
        
        let box = BindingBox<BindingProtocol>(object)
        bindingBoxs.append(box)
        let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
        mutableAttributedText.addAttributes(object.textAttributes, range: range)
        mutableAttributedText.addAttribute(bindingKey, value: box, range: range)
        textView.attributedText = mutableAttributedText
    }
    
    func addBindingObject<T: BindingProtocol>(_ object: T) {
        removeBindingObjects(in: textView.selectedRange)
        
        let box = BindingBox<BindingProtocol>(object)
        bindingBoxs.append(box)
        let insertedText = NSMutableAttributedString(string: "\(object.bindingText)", attributes: object.textAttributes)
        insertedText.addAttribute(bindingKey, value: box, range: NSRange(location: 0, length: insertedText.length))
        insertedText.append(NSAttributedString(string: " "))
        let mutableString = NSMutableAttributedString(attributedString: textView.attributedText)
        let oldSelectedRange = textView.selectedRange
        mutableString.replaceCharacters(in: oldSelectedRange, with: insertedText)
        textView.attributedText = mutableString
        textView.selectedRange = NSRange(location: oldSelectedRange.location + insertedText.length, length: 0)
    }
    
    func removeBindingObjects(in range: NSRange) {
        guard range.location != NSNotFound, range.location + range.length <= textView.attributedText.length else {
            return
        }
        textView.attributedText.enumerateAttributes(in: range, options: []) { (attrs, _, _) in
            if let bindingBox = attrs[bindingKey] as? BindingBox<BindingProtocol>,
                let index = bindingBoxs.firstIndex(where: { $0.uuid == bindingBox.uuid }) {
                let removedObject = bindingBoxs.remove(at: index)
                delegate?.bindingObjectDeleted(object: removedObject.value)
            }
        }
    }
    
    func findBindingRange(at index: Int) -> NSRange? {
        guard index >= 0, index < textView.attributedText.length else {
            return nil
        }
        var effectiveRange = NSRange(location: 0, length: 0)
        if textView.attributedText.attribute(bindingKey, at: index, longestEffectiveRange: &effectiveRange, in: NSRange(location: 0, length: textView.attributedText.length)) != nil {
            print("effectiveRange:", effectiveRange)
            return effectiveRange
        } else {
            return nil
        }
    }
}

extension BindingManager: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        delegate?.textDidChange(textView)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let attrs = delegate?.typingAttributes {
            textView.typingAttributes = attrs
        }
        
        // Non-multiple selection && deleteBackward action.
        // - Note: The deleted character maybe a multi-byte encoded character. eg: "emoji 😃, its text.count = 1, but attributeText.length = 2".
        //      Here it is judged whether the deleted range represents a single character, so it should not judged simply by "range.length == 1".
        let characterCountInReplacementRange = (textView.attributedText.string as NSString).substring(with: range).count
        if text == "" && characterCountInReplacementRange == 1 {
            var effectiveRange = NSRange(location: 0, length: 0)
            let rangeLimit = NSRange(location: 0, length: textView.attributedText.length)
            if let bindingBox = textView.attributedText.attribute(bindingKey, at: range.location, longestEffectiveRange: &effectiveRange, in: rangeLimit) as? BindingBox<BindingProtocol>,
                let index = bindingBoxs.firstIndex(where: { $0.uuid == bindingBox.uuid }) {
                let removedObject = bindingBoxs.remove(at: index)
                let mutableString = NSMutableAttributedString(attributedString: textView.attributedText)
                mutableString.deleteCharacters(in: effectiveRange)
                textView.attributedText = mutableString
                textView.selectedRange = NSRange(location: effectiveRange.location, length: 0)
                delegate?.bindingObjectDeleted(object: removedObject.value)
                return false
            }
            return true
            
        } else if range.length > 0 {
            removeBindingObjects(in: range)
            return true
        }
        
        return true
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        var newSelectedRange = textView.selectedRange
        if textView.selectedRange.length == 0 {
            if let bindingRange = findBindingRange(at: textView.selectedRange.location),
                bindingRange.location != textView.selectedRange.location {
                newSelectedRange.location = bindingRange.location + bindingRange.length
            }
        } else {
            var startPoint = textView.selectedRange.location
            var endPoint = textView.selectedRange.location + textView.selectedRange.length
            if let bindingRange = findBindingRange(at: startPoint) {
                startPoint = bindingRange.location
            }
            if let bindingRange = findBindingRange(at: endPoint) {
                endPoint = bindingRange.location + bindingRange.length
            }
            newSelectedRange = NSRange(location: startPoint, length: endPoint - startPoint)
        }
        
        if textView.selectedRange != newSelectedRange {
            textView.selectedRange = newSelectedRange
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        // For copying and pasting text into text view, you should ensure that the attributess of text are consistent, otherwise if the cursor is at "@xx" is different from the general text attribtues, the content's attributes pasted here will be same as "@xx".
        // To prevent this, we can reset it in the "textViewShouldBeginEditing(_:)" method.
        if let attrs = delegate?.typingAttributes {
            textView.typingAttributes = attrs
        }
        return true
    }
}
