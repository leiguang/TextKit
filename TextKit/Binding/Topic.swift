//
//  Topic.swift
//  TextKit
//
//  Created by Guang Lei  on 2019/2/12.
//  Copyright © 2019 Guang Lei . All rights reserved.
//

import UIKit

struct Topic {
    let id: String
    let title: String
}

extension Topic: BindingProtocol {
    var bindingText: String {
        return "#\(title)"
    }
    
    var textAttributes: [NSAttributedString.Key: Any] {
        return [
            .foregroundColor: UIColor.blue
        ]
    }
}
