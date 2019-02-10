//
//  ConfigurationViewController.swift
//  TextKit
//
//  Created by Guang Lei  on 2019/2/3.
//  Copyright © 2019 Guang Lei . All rights reserved.
//

import UIKit

/*
 
 使用 originalTextView 的内容填充 两个text view（otherTextView和thirdTextView）。
 
 Notes:
    将多个 Text Container 附加到一个 Layout Manager 会禁用编辑功能。如果必须保留编辑功能的话，那么一个 Text Container 只能附加到一个 Layout Manager 上。
    由于在 otherTextView 中的 Text Container 可以无限地调整大小，thirdTextView 永远不会得到任何文本。因此，我们必须指定文本应该从一个视图回流到其它视图，而不应该调整大小或者滚动，即：otherTextView.isScrollEnabled = false。
*/

class ConfigurationViewController: UIViewController {

    @IBOutlet weak var originalTextView: UITextView!
    @IBOutlet weak var otherContainerView: UIView!
    @IBOutlet weak var thirdContainerView: UIView!
    var otherTextView: UITextView!
    var thirdTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let url = Bundle.main.url(forResource: "poem", withExtension: "txt"),
            let text = try? String(contentsOf: url) else {
                fatalError("can't read poem.txt")
        }

        let sharedTextStorage = originalTextView.textStorage
        sharedTextStorage.replaceCharacters(in: NSRange(location: 0, length: originalTextView.text.count), with: text)
        originalTextView.scrollRangeToVisible(NSRange(location: 0, length: 0))

        // Create a new text view on the original text storage
        let otherLayoutManager = NSLayoutManager()
        sharedTextStorage.addLayoutManager(otherLayoutManager)
        
        let otherTextContainer = NSTextContainer()
        otherLayoutManager.addTextContainer(otherTextContainer)
        
        otherTextView = UITextView(frame: otherContainerView.bounds, textContainer: otherTextContainer)
        otherTextView.backgroundColor = otherContainerView.backgroundColor
        otherTextView.isScrollEnabled = false
        otherContainerView.addSubview(otherTextView)
        
        // Create a second text view on the new layout manager text storage
        let thirdTextContainer = NSTextContainer()
        otherLayoutManager.addTextContainer(thirdTextContainer)
        
        thirdTextView = UITextView(frame: thirdContainerView.bounds, textContainer: thirdTextContainer)
        thirdTextView.backgroundColor = thirdContainerView.backgroundColor
        thirdContainerView.addSubview(thirdTextView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        otherTextView.frame = otherContainerView.bounds
        thirdTextView.frame = thirdContainerView.bounds
    }
    
    @IBAction func endEditing(_ sender: Any) {
        view.endEditing(true)
    }
}
