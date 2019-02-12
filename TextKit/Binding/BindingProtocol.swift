//
//  BindingProtocol.swift
//  TextKit
//
//  Created by Guang Lei  on 2019/2/11.
//  Copyright © 2019 Guang Lei . All rights reserved.
//

import Foundation

protocol BindingProtocol {
    var bindingText: String { get }
    var textAttributes: [NSAttributedString.Key: Any] { get }
}
