//
//  OutliningLayoutManager.swift
//  TextKit
//
//  Created by Guang Lei  on 2019/2/10.
//  Copyright © 2019 Guang Lei . All rights reserved.
//

import UIKit

class OutliningLayoutManager: NSLayoutManager {

    override func drawUnderline(forGlyphRange glyphRange: NSRange, underlineType underlineVal: NSUnderlineStyle, baselineOffset: CGFloat, lineFragmentRect lineRect: CGRect, lineFragmentGlyphRange lineGlyphRange: NSRange, containerOrigin: CGPoint) {
        
        // Left border (== position) of first underlined glyph
        let firstPosition = location(forGlyphAt: glyphRange.location).x
        
        // Right border (== position + width) of last underlined glyph
        var lastPosition: CGFloat = 0.0
        
        // When link is not the last text in line, just use the location of the next glyph
        if NSMaxRange(glyphRange) < NSMaxRange(lineGlyphRange) {
            lastPosition = location(forGlyphAt: NSMaxRange(glyphRange)).x
        } else {
            // Otherwise get the end of the actually used rect
            lastPosition = lineFragmentUsedRect(forGlyphAt: NSMaxRange(glyphRange) - 1, effectiveRange: nil).width
        }
        
        var rect = lineRect
        
        // Inset line fragment to underlined area
        rect.origin.x += firstPosition
        rect.size.width = lastPosition - firstPosition
        
        // Offset line by container origin
        rect.origin.x += containerOrigin.x
        rect.origin.y += containerOrigin.y
        
        // Align line to pixel boundaries, passed rects may be
        rect = rect.insetBy(dx: 0.5, dy: 0.5)
        
        UIColor.green.set()
        UIBezierPath(rect: rect).stroke()
    }
}
