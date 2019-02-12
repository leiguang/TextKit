//
//  BindingBox.swift
//  TextKit
//
//  Created by Guang Lei  on 2019/2/11.
//  Copyright © 2019 Guang Lei . All rights reserved.
//

import Foundation

struct BindingBox<T> {
    let value: T
    let uuid = UUID()
    
    init(_ value: T) {
        self.value = value
    }
}
