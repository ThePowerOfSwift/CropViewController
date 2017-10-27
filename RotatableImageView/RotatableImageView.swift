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
    
    struct RotatableImageViewState {
        var rotation: CGFloat = 0.0
        var scale: CGFloat = 1.0
        var translation: CGPoint = CGPoint.zero
        
        static let identity = RotatableImageViewState()
    }
    
    /// Image to show
    var image: UIImage? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// Current state of rotate, translate, sale
    var state = RotatableImageViewState() {
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
    private func imageFrame(for state: RotatableImageViewState) -> CGRect {
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
        _setupGestureRecognizers()
    }
    
    override func sizeToFit() {
        self.frame = CGRect(origin: self.frame.origin, size: contentSize)
    }
    
    override func draw(_ rect: CGRect) {
        _draw(rect)
    }
    
    private func _scaleToFit(_ rect: CGRect) -> CGFloat {
        let defaultSize = imageFrame(for: RotatableImageViewState.identity).size
        let wScale = rect.width / defaultSize.width
        let hScale = rect.height / defaultSize.height
        return min(wScale, hScale)
    }
    
    private func _scaleToFill(_ rect: CGRect) -> CGFloat {
        let defaultSize = imageFrame(for: RotatableImageViewState.identity).size
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
    
    // gesture
    private lazy var pinchGestureRecognizer: UIPinchGestureRecognizer = {
        let gestureRecognizer = UIPinchGestureRecognizer()
        gestureRecognizer.delegate = self
        gestureRecognizer.addTarget(self, action: #selector(self.onPinched(gestureRecognizer:)))
        return gestureRecognizer
    }()
    
    private lazy var rotationGestureRecognizer: UIRotationGestureRecognizer = {
        let gestureRecognizer = UIRotationGestureRecognizer()
        gestureRecognizer.addTarget(self, action: #selector(self.onRotated(gestureRecognizer:)))
        return gestureRecognizer
    }()
    
    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let gestureRecognizer = UIPanGestureRecognizer()
        gestureRecognizer.addTarget(self, action: #selector(self.onPanned(gestureRecognizer:)))
        return gestureRecognizer
    }()
    
    private var initialRotation: CGFloat = 0.0
    private var initialScale: CGFloat = 1.0
    private var initialTranslation: CGPoint = CGPoint.zero
    
    private func restrictedValue<T: Comparable>(for value: T, min minValue: T, max maxValue: T) -> T {
        return max(min(value, maxValue), minValue)
    }
    
    /// Restrict translation not to go outside the screen
    private func _normalizedTranslation(for translation: CGPoint) -> CGPoint {
        let shortestEdge = min(contentSize.width, contentSize.height) * state.scale
        let maxTranslateX = bounds.width / 2 + shortestEdge / 2 - 5
        let maxTranslateY = bounds.height / 2 + shortestEdge / 2 - 5
        return CGPoint(x: restrictedValue(for: translation.x, min: -maxTranslateX, max: maxTranslateX),
                       y: restrictedValue(for: translation.y, min: -maxTranslateY, max: maxTranslateY))
    }
    
    private func _normalizedScale(for scale: CGFloat) -> CGFloat {
        let niceScale = _scaleToFit(bounds.insetBy(dx: 50, dy: 50))
        let minimumScale: CGFloat = niceScale * 0.3
        let maximumScale: CGFloat = niceScale * 8.0
        return restrictedValue(for: scale, min: minimumScale, max: maximumScale)
    }
    
    private func _setupGestureRecognizers() {
        addGestureRecognizer(pinchGestureRecognizer)
        addGestureRecognizer(rotationGestureRecognizer)
        addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc func onRotated(gestureRecognizer: UIRotationGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            initialRotation = state.rotation
        case .changed:
            state.rotation = initialRotation + gestureRecognizer.rotation
        case .ended:
            state.rotation = initialRotation + gestureRecognizer.rotation
        case .failed, .cancelled, .possible:
            break
        }
    }
    
    @objc func onPinched(gestureRecognizer: UIPinchGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            initialScale = state.scale
        case .changed:
            state.scale = _normalizedScale(for: initialScale * gestureRecognizer.scale)
        case .ended:
            state.scale = _normalizedScale(for: initialScale * gestureRecognizer.scale)
        case .failed, .cancelled, .possible:
            break
        }
    }
    
    @objc func onPanned(gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            initialTranslation = state.translation
        case .changed:
            let gestureTranslation = gestureRecognizer.translation(in: gestureRecognizer.view)
            let translation = CGPoint(x: initialTranslation.x + gestureTranslation.x, y: initialTranslation.y + gestureTranslation.y)
            state.translation = _normalizedTranslation(for: translation)
        case .ended:
            let gestureTranslation = gestureRecognizer.translation(in: gestureRecognizer.view)
            let translation = CGPoint(x: initialTranslation.x + gestureTranslation.x, y: initialTranslation.y + gestureTranslation.y)
            state.translation = _normalizedTranslation(for: translation)
        case .failed, .cancelled, .possible:
            break
        }
    }
}

extension RotatableImageView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
