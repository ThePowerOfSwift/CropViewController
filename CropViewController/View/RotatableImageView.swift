//
//  RotatableImageView.swift
//  RotatableImageView
//
//  Created by ST20591 on 2017/10/26.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import UIKit

/// The view to show image with transformed by rotation, scale, translation.
/// Set isUserInteractionEnabled = false to disable transforming.
final class RotatableImageView: UIView {
    
    private(set) lazy var manager: TransformStateManager = {
       let manager = TransformStateManager()
        manager.delegate = self
        return manager
    }()
    
    var state: TransformState {
        set {
            manager.state = newValue
        }
        get {
            return manager.state
        }
    }
    
    /// Image to show
    var image: UIImage? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// Size of the image
    var contentSize: CGSize {
        return image?.size ?? .zero
    }
    
    /// Calcurates the frame of image on the condition of specified state.
    ///
    /// - parameter state: The conditon to calculate the frame on. (ignores rotation)
    ///
    /// - returns: Calculated rect
    private func imageFrame(for state: TransformState) -> CGRect {
        return CGRect(x: bounds.midX + state.translation.x, y: bounds.midY + state.translation.y, width: contentSize.width * state.scale, height: contentSize.height * state.scale)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _commonInit()
    }
    
    private func _commonInit() {
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        manager.setupGestureRecognizers(on: self)
    }
    
    override func sizeToFit() {
        self.frame = CGRect(origin: self.frame.origin, size: contentSize)
    }
    
    override func draw(_ rect: CGRect) {
        _draw(rect)
    }
    
    private func _scaleToFit(_ rect: CGRect) -> CGFloat {
        let defaultSize = imageFrame(for: TransformState.identity).size
        let wScale = rect.width / defaultSize.width
        let hScale = rect.height / defaultSize.height
        return min(wScale, hScale)
    }
    
    private func _scaleToFill(_ rect: CGRect) -> CGFloat {
        let defaultSize = imageFrame(for: TransformState.identity).size
        let wScale = rect.width / defaultSize.width
        let hScale = rect.height / defaultSize.height
        return max(wScale, hScale)
    }
    
    /// Adjust iamge scale to fit rect.
    ///
    /// - parameter rect: The rectangle to fit.
    func adjustScaleToFit(_ rect: CGRect) {
        state.scale = _scaleToFit(rect)
    }
    
    /// Adjust iamge scale to fit rect.
    ///
    /// - parameter rect: The rectangle to fill.
    func adjustScaleToFill(_ rect: CGRect) {
        state.scale = _scaleToFill(rect)
    }
    
    /// draw scale = 1.0 image and crop with converted rect.
    ///
    /// - parameter frame: The frame to crop the image.
    ///
    /// - returns: The cropped image
    func getImage(of frame: CGRect) -> UIImage? {
        let drawScale = 1 / state.scale
        let drawRect = CGRect(x: 0, y: 0, width: bounds.size.width * drawScale, height: bounds.size.height * drawScale)
        
        UIGraphicsBeginImageContext(drawRect.size)
        defer {
            UIGraphicsEndImageContext()
        }
        guard let context = _draw(drawRect, drawScale: drawScale) else {
            return nil
        }
        let convertedFrame = CGRect(x: frame.origin.x * drawScale, y: frame.origin.y * drawScale, width: frame.width * drawScale, height: frame.width * drawScale)
        return context.makeImage()?.cropping(to: convertedFrame).map { UIImage(cgImage: $0) }
    }
    
    @discardableResult
    private func _draw(_ rect: CGRect, drawScale: CGFloat = 1.0) -> CGContext? {
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        guard let image = image else {
            return context
        }
        
        // clear
        context.clear(rect)
        
        // background
        context.setFillColor((backgroundColor ?? UIColor.clear).cgColor)
        context.fill(rect)
        
        // Save original coordinate system
        context.saveGState()
        
        context.translateBy(x: rect.midX, y: rect.midY)
        
        // translate
        context.translateBy(x: state.translation.x * drawScale, y: state.translation.y * drawScale)
        
        let imageFrame = CGRect(origin: .zero, size: image.size)
        
        // rotate
        context.rotate(by: state.rotation)
        
        // scale
        context.scaleBy(x: state.scale * drawScale, y: state.scale * drawScale)
        
        // draw
        image.draw(in: imageFrame.offsetBy(dx: -imageFrame.width / 2, dy: -imageFrame.width / 2))
        
        // Restore coordinate system
        context.restoreGState()
        
        return context
    }
}

extension RotatableImageView: TransformStateManagerDelegate {
    func onStateChanged(_ state: TransformState) {
        setNeedsDisplay()
    }
    
    private func restrictedValue<T: Comparable>(for value: T, min minValue: T, max maxValue: T) -> T {
        return max(min(value, maxValue), minValue)
    }
    
    func normalizedScale(for scale: CGFloat) -> CGFloat {
        let niceScale = _scaleToFit(bounds.insetBy(dx: 50, dy: 50))
        let minimumScale: CGFloat = niceScale * 0.3
        let maximumScale: CGFloat = niceScale * 8.0
        return restrictedValue(for: scale, min: minimumScale, max: maximumScale)
    }
    
    /// Restrict translation not to go outside the screen
    func normalizedTranslation(for translation: CGPoint) -> CGPoint {
        let shortestEdge = min(contentSize.width, contentSize.height) * state.scale
        let maxTranslateX = bounds.width / 2 + shortestEdge / 2 - 5
        let maxTranslateY = bounds.height / 2 + shortestEdge / 2 - 5
        return CGPoint(x: restrictedValue(for: translation.x, min: -maxTranslateX, max: maxTranslateX),
                       y: restrictedValue(for: translation.y, min: -maxTranslateY, max: maxTranslateY))
    }
}
