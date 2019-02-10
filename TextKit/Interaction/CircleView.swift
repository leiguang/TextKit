//
//  CircleView.swift
//  TextKit
//
//  Created by Guang Lei  on 2019/2/10.
//  Copyright © 2019 Guang Lei . All rights reserved.
//

import UIKit

class CircleView: UIView {

    override func draw(_ rect: CGRect) {
        tintColor.setFill()
        UIBezierPath(ovalIn: bounds).fill()
    }
}
