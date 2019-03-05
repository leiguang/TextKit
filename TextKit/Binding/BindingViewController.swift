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
        
        textView.bindingManager.delegate = self
        
        inspectCharacterLength()
//        addDefaultText()
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
    
    func addDefaultText() {
        let friendList = [Friend(id: "1", name: "朋友1"), Friend(id: "2", name: "朋友2")]
        let topicList = [Topic(id: "1", title: "话题1"), Topic(id: "2", title: "话题2")]
        let text = "#话题1##话题1##话题2#n #话题2##话题2c#ad//@朋友1@1112 @朋友231@朋友3@ef*&^HN"
        let mutableAttributedText = NSMutableAttributedString(string: text, attributes: typingAttributes)
        textView.attributedText = mutableAttributedText
        let list = friendList.map { $0.bindingText } + topicList.map { $0.bindingText }
        let pattern = list.joined(separator: "|")
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            regex.enumerateMatches(in: text, options: [], range: NSRange(location: 0, length: text.count)) { (checkingResult, _, _) in
                guard let checkingResult = checkingResult else {
                    return
                }
                let matchedRange = checkingResult.range
                let matchedText = (text as NSString).substring(with: matchedRange)
                print("range:", matchedRange, matchedText)
                if let friend = friendList.first(where: { matchedText == $0.bindingText }) {
                    self.textView.bindingManager.addBindingObject(friend, in: matchedRange)
                } else if let topic = topicList.first(where: { matchedText == $0.bindingText }) {
                    self.textView.bindingManager.addBindingObject(topic, in: matchedRange)
                }
            }
        } catch {
            print(error)
        }
    }
    
    @IBAction func addFriend(_ sender: Any) {
        let friend = BindingViewController.getARandomFriend()
        friends.append(friend)
        textView.bindingManager.addBindingObject(friend)
    }
    
    @IBAction func addTopic(_ sender: Any) {
        let topic = BindingViewController.getARandomTopic()
        topics.append(topic)
        textView.bindingManager.addBindingObject(topic)
    }
    @IBAction func endEditing(_ sender: Any) {
        view.endEditing(true)
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

extension BindingViewController: BindingManagerDelegate {
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
