//
//  LayoutingViewController.swift
//  TextKit
//
//  Created by Guang Lei  on 2019/2/3.
//  Copyright © 2019 Guang Lei . All rights reserved.
//

import UIKit

class LayoutingViewController: UIViewController {

    // Text storage must be held strongly, only the default storage is retained by the text view.
    let textStorage = LinkDetectingTextStorage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let url = Bundle.main.url(forResource: "layout", withExtension: "txt"),
            let text = try? String(contentsOf: url) else {
                fatalError("can't read layout.txt")
        }

        // Create componentes
        
        let layoutManager = OutliningLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        
        let textContainer = NSTextContainer()
        layoutManager.addTextContainer(textContainer)
        
        let textView = UITextView(frame: CGRect(x: 20, y: 100, width: 350, height: 400), textContainer: textContainer)
        textView.keyboardDismissMode = .onDrag
        view.addSubview(textView)
        
        // Set delegate
        layoutManager.delegate = self
        
        textStorage.replaceCharacters(in: NSRange(location: 0, length: 0), with: text)
    }
    
    @IBAction func endEditing(_ sender: Any) {
        view.endEditing(true)
    }
}

extension LayoutingViewController: NSLayoutManagerDelegate {
    
    func layoutManager(_ layoutManager: NSLayoutManager, shouldBreakLineByWordBeforeCharacterAt charIndex: Int) -> Bool {
        var range = NSRange(location: 0, length: 0)
        guard let linkURL = layoutManager.textStorage?.attribute(.link, at: charIndex, effectiveRange: &range) as? URL else {
            return true
        }
        print("lingURL: ", linkURL)
        
        // Do not break lines in links unless absolutely required.
        if charIndex > range.location && charIndex <= NSMaxRange(range) {
            return false
        } else {
            return true
        }
    }
    
    // Let line spacing grow with text length.
    func layoutManager(_ layoutManager: NSLayoutManager, lineSpacingAfterGlyphAt glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
        return CGFloat(glyphIndex / 100)
    }
    
    func layoutManager(_ layoutManager: NSLayoutManager, paragraphSpacingAfterGlyphAt glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
        return 10.0
    }
}
