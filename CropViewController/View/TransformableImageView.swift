//
//  TransformableImageView.swift
//  TransformableImageView
//
//  Created by ST20591 on 2017/10/26.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import UIKit

/// The view to show image with transformed by rotation, scale, translation.
/// Set isUserInteractionEnabled = false to disable transforming.
public final class TransformableImageView: UIView {
    
    private static let _niceFrameInset: CGFloat = 50
    
    // MARK: - Properties
    
    private lazy var manager: TransformStateManager = {
       let manager = TransformStateManager()
        manager.delegate = self
        return manager
    }()
    
    /// UIView to show image
    fileprivate var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .center
        return view
    }()
    
    /// Image to show
    public var image: UIImage? {
        didSet {
            imageView.image = image
            imageView.sizeToFit()
        }
    }
    
    /// Current state of transform
    public var state: TransformState {
        set {
            manager.state = newValue
        }
        get {
            return manager.state
        }
    }
    
    /// Size of the image (Get-only)
    public var contentSize: CGSize {
        return image?.size ?? .zero
    }
    
    public var defaultImageFrame: CGRect {
        return _imageFrame()
    }
    
    public var imageFrame: CGRect {
        return _imageFrame(for: state)
    }
    
    // MARK: - Initializers
    
    required public init?(coder aDecoder: NSCoder) {
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
        manager.addGestureRecognizers(to: self)
        addSubview(imageView)
    }
    
    // MARK: - UIView methods
    
    override public func sizeToFit() {
        self.frame = CGRect(origin: self.frame.origin, size: imageFrame.size)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        imageView.center = self.center
    }
    
    // MARK: - Public functions
    
    /// Adjust image scale and translation to fit rect.
    ///
    /// - parameter rect: The rectangle to fit.
    public func transformToFit(_ rect: CGRect) {
        manager.state.translation = CGPoint(x: rect.midX - self.center.x, y: rect.midY - self.center.y)
        manager.state.scale = defaultImageFrame.size.aspectFitScale(to: rect.size)
        manager.state.rotation = 0.0
    }
    
    /// Adjust image scale and translation to fit rect.
    ///
    /// - parameter rect: The rectangle to fill.
    public func transformToFill(_ rect: CGRect) {
        manager.state.translation = CGPoint(x: rect.midX - self.center.x, y: rect.midY - self.center.y)
        manager.state.scale = defaultImageFrame.size.aspectFillScale(to: rect.size)
        manager.state.rotation = 0.0
    }
    
    /// Draw image with original resolution, and crop with converted path.
    ///
    /// - parameter frame: The frame to crop the image.
    ///
    /// - returns: The cropped image
    public func getCroppedImage(with path: UIBezierPath) -> UIImage? {
        guard manager.state.scale != 0 else {
            return nil
        }
        
        let drawScale = 1 / manager.state.scale
        let drawRect = CGRect(origin: .zero, size: bounds.size.uniformlyScaled(by: drawScale))
        
        UIGraphicsBeginImageContext(drawRect.size)
        defer {
            UIGraphicsEndImageContext()
        }
        
        path.scaled(by: drawScale)?.addClip()
        
        guard let context = _draw(drawRect, drawScale: drawScale) else {
            return nil
        }
        
        let frame = path.bounds
        let convertedFrame = CGRect(x: frame.origin.x * drawScale, y: frame.origin.y * drawScale, width: frame.width * drawScale, height: frame.width * drawScale)
        
        return context.makeImage()?.cropping(to: convertedFrame).map { UIImage(cgImage: $0) }
    }
    
    /// Draw image with original resolution, and crop with converted rect.
    ///
    /// - parameter frame: The frame to crop the image.
    ///
    /// - returns: The cropped image
    public func getCroppedImage(of frame: CGRect) -> UIImage? {
        guard manager.state.scale != 0 else {
            return nil
        }
        
        let drawScale = 1 / manager.state.scale
        let drawRect = CGRect(origin: .zero, size: bounds.size.uniformlyScaled(by: drawScale))
        
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
    
    // MARK: - Private functions
    
    /// Calcurates the frame of image on the condition of specified state.
    ///
    /// - parameter state: The conditon to calculate the frame on.
    ///
    /// - returns: Calculated rect
    private func _imageFrame(for state: TransformState = TransformState.identity) -> CGRect {
        let imageSize = contentSize
            .uniformlyScaled(by: state.scale)
            .applying(CGAffineTransform(rotationAngle: state.rotation))
        return CGRect(origin: CGPoint(x: imageSize.width / 2, y: imageSize.height / 2), size: imageSize)
            .offsetBy(dx: state.translation.x, dy: state.translation.y)
            .offsetBy(dx: bounds.midX, dy: bounds.midY)
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
        context.translateBy(x: manager.state.translation.x * drawScale, y: manager.state.translation.y * drawScale)
        
        let imageFrame = CGRect(origin: .zero, size: image.size)
        
        // rotate
        context.rotate(by: manager.state.rotation)
        
        // scale
        context.scaleBy(x: manager.state.scale * drawScale, y: manager.state.scale * drawScale)
        
        // draw
        image.draw(in: imageFrame.offsetBy(dx: -imageFrame.width / 2, dy: -imageFrame.height / 2))
        
        // Restore coordinate system
        context.restoreGState()
        
        return context
    }
}

extension TransformableImageView: TransformStateManagerDelegate {
    
    // MARK: - TransformStateManagerDelegate
    
    func onStateChanged(_ state: TransformState) {
        imageView.transform = state.asCGAffineTransform()
    }
    
    func normalizedScale(for scale: CGFloat) -> CGFloat {
        let niceSize = bounds.insetBy(dx: TransformableImageView._niceFrameInset,
                                      dy: TransformableImageView._niceFrameInset).size
        let niceScale = defaultImageFrame.size.aspectFitScale(to: niceSize)
        let minimumScale: CGFloat = niceScale * 0.3
        let maximumScale: CGFloat = max(1.0, niceScale * 8.0)
        return scale.clamp(min: minimumScale, max: maximumScale)
    }
    
    /// Restrict translation not to go outside the screen
    func normalizedTranslation(for translation: CGPoint) -> CGPoint {
        let shortestEdge = min(contentSize.width, contentSize.height) * manager.state.scale
        let maxTranslateX = bounds.width / 2 + shortestEdge / 2 - 5
        let maxTranslateY = bounds.height / 2 + shortestEdge / 2 - 5
        return CGPoint(x: translation.x.clamp(min: -maxTranslateX, max: maxTranslateX),
                       y: translation.y.clamp(min: -maxTranslateY, max: maxTranslateY))
    }
}
