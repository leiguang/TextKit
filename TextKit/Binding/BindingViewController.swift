//
//  BindingViewController.swift
//  TextKit
//
//  Created by Guang Lei  on 2019/2/11.
//  Copyright © 2019 Guang Lei . All rights reserved.
//

import UIKit

class BindingViewController: UIViewController {

    @IBOutlet weak var textView: BindingTextView!
    
    var friends: [Friend] = []
    var topics: [Topic] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.bindingDelegate = self
        
        inspectCharacterLength()
    }
    
    func inspectCharacterLength() {
        // the character "我": count = 1, length = 1.
        // the emoji "⭐️": count = 1, length = 2.
        let text = "我⭐️"
        let attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttributes([.backgroundColor: UIColor.red], range: NSRange(location: 0, length: attributedText.length))
        textView.attributedText = attributedText
        print("text:", text)
        print("text.count:", text.count)
        print("attributedText.string.count:", attributedText.string.count)
        print("attributedText.length:", attributedText.length)
        print("text.rangeOf'我':", (text as NSString).range(of: "我"))
        print("text.rangeOf'⭐️':", (text as NSString).range(of: "⭐️"))
    }
    
    @IBAction func addFriend(_ sender: Any) {
        let friend = BindingViewController.getARandomFriend()
        friends.append(friend)
        textView.addBindingObject(friend)
    }
    
    @IBAction func addTopic(_ sender: Any) {
        let topic = BindingViewController.getARandomTopic()
        topics.append(topic)
        textView.addBindingObject(topic)
    }
    
    class func getARandomFriend() -> Friend {
        let names = ["燕一❤️", "孔⭐️二", "🌈张三"]
        let randomIndex = Int.random(in: 0..<names.count)
        return Friend(id: UUID().uuidString, name: names[randomIndex])
    }
    
    class func getARandomTopic() -> Topic {
        let titles = ["李四", "王五", "赵六"]
        let randomIndex = Int.random(in: 0..<titles.count)
        return Topic(id: UUID().uuidString, title: titles[randomIndex])
    }
}

extension BindingViewController: BindingTextViewDelegate {
    var typingAttributes: [NSAttributedString.Key: Any] {
        return [
            .foregroundColor: UIColor.black
        ]
    }
    
    func bindingObjectDeleted(object: BindingProtocol) {
        if let friend = object as? Friend {
            print("deleted friend:", friend)
        } else if let topic = object as? Topic {
            print("deleted topic:", topic)
        }
    }
    
    func textDidChange(_ textView: UITextView) {
        
    }
}
