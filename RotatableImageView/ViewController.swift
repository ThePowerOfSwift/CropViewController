//
//  ViewController.swift
//  RotatableImageView
//
//  Created by ST20591 on 2017/10/25.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import UIKit

/// 中心に画像を描画する
/// TODO: automatic scale on setting image
class RotatableImageView: UIView {
    
    struct RotatableImageViewState {
        var rotation: CGFloat = 0.0
        var scale: CGFloat = 1.0
        var translation: CGPoint = CGPoint.zero
    }
    
    var image: UIImage? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var state = RotatableImageViewState() {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var contentSize: CGSize {
        return image?.size ?? .zero
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
    
    /// draw scale = 1.0 image and crop with converted rect.
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
        
        // 座標系を一時退避
        context.saveGState()
        
        // 座標系を中心に
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
        
        // 座標系を戻す
        context.restoreGState()
        
        return context
    }
    
    override func draw(_ rect: CGRect) {
        _draw(rect)
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

class ViewController: UIViewController {
    
    private lazy var imageView: RotatableImageView = {
        let imageView = RotatableImageView(frame: view.bounds)
        imageView.image = #imageLiteral(resourceName: "sample.png")
        imageView.state.scale = 2 / 3
        imageView.state.rotation = CGFloat.pi / 3 * 2
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        
        view.addSubview(imageView)
        
        let sampleCropRect = CGRect(origin: CGPoint(x: imageView.bounds.midX - 100, y: imageView.bounds.midY - 100), size: CGSize(width: 200, height: 200))
        
        let cropView = UIView(frame: sampleCropRect)
        cropView.backgroundColor = .clear
        cropView.layer.borderColor = UIColor.white.cgColor
        cropView.layer.borderWidth = 2.0
        cropView.isUserInteractionEnabled = false
        view.addSubview(cropView)

        Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { [weak self] _ in
            self?.crop(sampleCropRect)
        }
    }
    
    func crop(_ rect: CGRect) {
        let image = imageView.getImage(of: rect)
        imageView.image = image
        imageView.state.translation = .zero
        imageView.state.rotation = 0.0
    }
}
