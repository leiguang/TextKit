//
//  Friend.swift
//  TextKit
//
//  Created by Guang Lei  on 2019/2/11.
//  Copyright © 2019 Guang Lei . All rights reserved.
//

import UIKit

struct Friend {
    let id: String
    let name: String
}

extension Friend: BindingProtocol {
    var bindingText: String {
        return "@\(name)"
    }
    
    var textAttributes: [NSAttributedString.Key: Any] {
        return [
            .foregroundColor: UIColor.green,
        ]
    }
}
