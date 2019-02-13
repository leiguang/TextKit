//
//  BindingTextView.swift
//  TextKit
//
//  Created by Guang Lei  on 2019/2/11.
//  Copyright © 2019 Guang Lei . All rights reserved.
//

import UIKit

class BindingTextView: UITextView {
    
    var bindingManager: BindingManager!
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        bindingManager = BindingManager(textView: self)
        delegate = bindingManager
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
}
