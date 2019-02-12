//
//  BindingTextView.swift
//  TextKit
//
//  Created by Guang Lei  on 2019/2/11.
//  Copyright © 2019 Guang Lei . All rights reserved.
//

import UIKit

/*
 - Note:
    The text may contain multi-byte encoded character. eg: "emoji 😃, its text.count = 1, but attributeText.length = 2". So remember using attributedText.length to calculate range and length in BindingTextView.
 */

protocol BindingTextViewDelegate: class {
    var typingAttributes: [NSAttributedString.Key: Any] { get }
    func bindingObjectDeleted(object: BindingProtocol)
    func textDidChange(_ textView: UITextView)
}

class BindingTextView: UITextView {
    
    // Binding
    let bindingKey = NSAttributedString.Key("textBinding")
    
    weak var bindingDelegate: BindingTextViewDelegate?
    
    private var bindingBoxs: [BindingBox<BindingProtocol>] = [] {
        didSet {
            print("bindingObjects:", bindingBoxs.map { $0.value.bindingText + ":" + ($0.uuid.uuidString as NSString).substring(to: 6) })
        }
    }
    
    var bindingObjects: [BindingProtocol] {
        return bindingBoxs.map { $0.value }
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        delegate = self
        if let attrs = bindingDelegate?.typingAttributes {
            typingAttributes = attrs
        }
    }
    
    override var attributedText: NSAttributedString! {
        didSet {
            attributedTextDidChange()
        }
    }
    
    @objc private func attributedTextDidChange() {
        if let delegate = delegate, let textViewDidChange = delegate.textViewDidChange {
            textViewDidChange(self)
        }
    }
    
    func addBindingObject<T: BindingProtocol>(_ object: T) {
        removeBindingObjects(in: selectedRange)
        
        let box = BindingBox<BindingProtocol>(object)
        bindingBoxs.append(box)
        let insertedText = NSMutableAttributedString(string: "\(object.bindingText)", attributes: object.textAttributes)
        insertedText.addAttribute(bindingKey, value: box, range: NSRange(location: 0, length: insertedText.length))
        insertedText.append(NSAttributedString(string: " "))
        let mutableString = NSMutableAttributedString(attributedString: attributedText)
        let oldSelectedRange = selectedRange
        mutableString.replaceCharacters(in: oldSelectedRange, with: insertedText)
        attributedText = mutableString
        selectedRange = NSRange(location: oldSelectedRange.location + insertedText.length, length: 0)
    }
    
    func removeBindingObjects(in range: NSRange) {
        attributedText.enumerateAttributes(in: range, options: []) { (attrs, _, _) in
            if let bindingBox = attrs[bindingKey] as? BindingBox<BindingProtocol>,
                let index = bindingBoxs.firstIndex(where: { $0.uuid == bindingBox.uuid }) {
                let removedObject = bindingBoxs.remove(at: index)
                bindingDelegate?.bindingObjectDeleted(object: removedObject.value)
            }
        }
    }
    
    func findBindingRange(at index: Int) -> NSRange? {
        guard index >= 0, index < attributedText.length else {
            return nil
        }
        var effectiveRange = NSRange(location: 0, length: 0)
        if attributedText.attribute(bindingKey, at: index, longestEffectiveRange: &effectiveRange, in: NSRange(location: 0, length: attributedText.length)) != nil {
            print("effectiveRange:", effectiveRange)
            return effectiveRange
        } else {
            return nil
        }
    }
}

extension BindingTextView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        bindingDelegate?.textDidChange(textView)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let attrs = bindingDelegate?.typingAttributes {
            typingAttributes = attrs
        }
  
        // Non-multiple selection && deleteBackward action.
        // - Note: The deleted character maybe a multi-byte encoded character. eg: "emoji 😃, its text.count = 1, but attributeText.length = 2". Here it is judged whether the deleted range represents a single character, so it should not judged simply by "range.length == 1".
        let characterCountInReplacementRange = (attributedText.string as NSString).substring(with: range).count
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
                bindingDelegate?.bindingObjectDeleted(object: removedObject.value)
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
        var newSelectedRange = selectedRange
        if selectedRange.length == 0 {
            if let bindingRange = findBindingRange(at: selectedRange.location),
                bindingRange.location != selectedRange.location {
                newSelectedRange.location = bindingRange.location + bindingRange.length
            }
        } else {
            var startPoint = selectedRange.location
            var endPoint = selectedRange.location + selectedRange.length
            if let bindingRange = findBindingRange(at: startPoint) {
                startPoint = bindingRange.location
            }
            if let bindingRange = findBindingRange(at: endPoint) {
                endPoint = bindingRange.location + bindingRange.length
            }
            newSelectedRange = NSRange(location: startPoint, length: endPoint - startPoint)
        }
        
        if selectedRange != newSelectedRange {
            selectedRange = newSelectedRange
        }
    }
}
