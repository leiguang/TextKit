//
//  InteractionViewController.swift
//  TextKit
//
//  Created by Guang Lei  on 2019/2/10.
//  Copyright © 2019 Guang Lei . All rights reserved.
//

import UIKit

class InteractionViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var circleView: CircleView!
    @IBOutlet weak var clippyView: UIImageView!
    
    var panOffset: CGPoint = .zero
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Load text
        guard let url = Bundle.main.url(forResource: "lorem", withExtension: "txt"),
            let text = try? String(contentsOf: url) else {
                fatalError("can't read lorem.txt")
        }
        textView.textStorage.replaceCharacters(in: NSRange(location: 0, length: textView.text.count), with: text)
        
        // Delegate
        textView.delegate = self
        clippyView.isHidden = true
        
        // Set up circle pan
        circleView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(circlePan)))
        
        // Enable hyphenation
        textView.layoutManager.hyphenationFactor = 1.0
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateExclusionPaths()
    }
    
    // MARK: - Exclusion
    
    @objc func circlePan(_ pan: UIPanGestureRecognizer) {
        // Capture offset in view on begin
        if case .began = pan.state {
            panOffset = pan.location(in: circleView)
        }
        
        // Update view location
        let location = pan.location(in: view)
        var circleCenter = circleView.center
        
        circleCenter.x = location.x - panOffset.x + circleView.frame.width / 2
        circleCenter.y = location.y - panOffset.y + circleView.frame.height / 2
        circleView.center = circleCenter
        
        // Update exclusion path
        updateExclusionPaths()
    }

    func updateExclusionPaths() {
        var ovalFrame = textView.convert(circleView.bounds, from: circleView)
        
        // Since text container does not know about the inset, we must shift the frame to container coordinates
        ovalFrame.origin.x -= textView.textContainerInset.left
        ovalFrame.origin.y -= textView.textContainerInset.top
        
        // Simply set the exclusion path
        let ovalPath = UIBezierPath(ovalIn: ovalFrame)
        textView.textContainer.exclusionPaths = [ovalPath]
        
        // And don't forget clippy
        updateClippy()
    }
 
    func updateClippy() {
        // Zero length selection hide clippy
        guard textView.selectedRange.length > 0 else {
            clippyView.isHidden = true
            return
        }
        
        // Find last rect of selection
        let glyphRange = textView.layoutManager.glyphRange(forCharacterRange: textView.selectedRange, actualCharacterRange: nil)
        var lastRect: CGRect = .zero
        textView.layoutManager.enumerateEnclosingRects(forGlyphRange: glyphRange, withinSelectedGlyphRange: glyphRange, in: textView.textContainer) { (rect, _) in
            lastRect = rect
        }
        
        // Position clippy at bottom-right of selection
        var clippyCenter: CGPoint = .zero
        clippyCenter.x = lastRect.maxX + textView.textContainerInset.left
        clippyCenter.y = lastRect.maxY + textView.textContainerInset.top
        
        clippyCenter = textView.convert(clippyCenter, to: view)
        clippyCenter.x += clippyView.bounds.width / 2
        clippyCenter.y += clippyView.bounds.height / 2
        
        clippyView.isHidden = false
        clippyView.center = clippyCenter
    }
}

extension InteractionViewController: UITextViewDelegate {
    
    // MARK: - Selection tracking
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        updateClippy()
    }
}
