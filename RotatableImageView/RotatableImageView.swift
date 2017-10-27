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
    
    /// Adjust iamge scale to fit rect.
    ///
    /// - parameter rect: The rectangle to fit.
    func adjustScaleToFit(_ rect: CGRect) {
        let defaultSize = imageFrame(for: RotatableImageViewState.identity).size
        let wScale = rect.width / defaultSize.width
        let hScale = rect.height / defaultSize.height
        state.scale = min(wScale, hScale)
    }
    
    /// Adjust iamge scale to fit rect.
    ///
    /// - parameter rect: The rectangle to fill.
    func adjustScaleToFill(_ rect: CGRect) {
        let defaultSize = imageFrame(for: RotatableImageViewState.identity).size
        let wScale = rect.width / defaultSize.width
        let hScale = rect.height / defaultSize.height
        state.scale = max(wScale, hScale)
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
    
    let minimumScale: CGFloat = 0.5
    let maximumScale: CGFloat = 8.0
    private func _normalizedScale(for scale: CGFloat) -> CGFloat {
        return max(min(scale, maximumScale), minimumScale)
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
            let translation = gestureRecognizer.translation(in: gestureRecognizer.view)
            state.translation = CGPoint(x: initialTranslation.x + translation.x, y: initialTranslation.y + translation.y)
        case .ended:
            let translation = gestureRecognizer.translation(in: gestureRecognizer.view)
            state.translation = CGPoint(x: initialTranslation.x + translation.x, y: initialTranslation.y + translation.y)
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
