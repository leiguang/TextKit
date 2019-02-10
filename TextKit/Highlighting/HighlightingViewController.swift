//
//  HighlightingViewController.swift
//  TextKit
//
//  Created by Guang Lei  on 2019/2/3.
//  Copyright © 2019 Guang Lei . All rights reserved.
//

import UIKit

class HighlightingViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    // Text storage must be held strongly, only the default storage is retained by the text view.
    let textStorage = HighlightingTextStorage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let url = Bundle.main.url(forResource: "iText", withExtension: "txt"),
            let text = try? String(contentsOf: url) else {
                fatalError("can't read iText.txt")
        }

        // Replace text storage
        textStorage.addLayoutManager(textView.layoutManager)
        
        // Load iText
        textStorage.replaceCharacters(in: NSRange(location: 0, length: 0), with: text)
    }
    
    @IBAction func endEditing(_ sender: Any) {
        view.endEditing(true)
    }
}
