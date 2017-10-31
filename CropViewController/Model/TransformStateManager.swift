//
//  TransformStateManager.swift
//  CropViewController
//
//  Created by はるふ on 2017/10/31.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import UIKit

protocol TransformStateManagerDelegate: class {
    func normalizedScale(for scale: CGFloat) -> CGFloat
    func normalizedTranslation(for translation: CGPoint) -> CGPoint
    func normalizedRotation(for rotation: CGFloat) -> CGFloat
    func onStateChanged(_ state: TransformState)
}

extension TransformStateManagerDelegate {
    func normalizedScale(for scale: CGFloat) -> CGFloat {
        return scale
    }
    func normalizedTranslation(for translation: CGPoint) -> CGPoint {
        return translation
    }
    func normalizedRotation(for rotation: CGFloat) -> CGFloat {
        return rotation
    }
    func onStateChanged(_ state: TransformState) {
    }
}

final class TransformStateManager: NSObject {
    
    // MARK: - Public Properties
    
    public weak var delegate: TransformStateManagerDelegate?
    
    public var state = TransformState() {
        didSet {
            delegate?.onStateChanged(state)
        }
    }
    
    // MARK: - Private Properties
    
    private lazy var pinchTransformGestureRecognizer: UIPinchGestureRecognizer = {
        let gestureRecognizer = UIPinchGestureRecognizer()
        gestureRecognizer.delegate = self
        gestureRecognizer.addTarget(self, action: #selector(self.onPinched(gestureRecognizer:)))
        return gestureRecognizer
    }()
    
    private lazy var rotationTransformGestureRecognizer: UIRotationGestureRecognizer = {
        let gestureRecognizer = UIRotationGestureRecognizer()
        gestureRecognizer.delegate = self
        gestureRecognizer.addTarget(self, action: #selector(self.onRotated(gestureRecognizer:)))
        return gestureRecognizer
    }()
    
    private lazy var panTransformGestureRecognizer: UIPanGestureRecognizer = {
        let gestureRecognizer = UIPanGestureRecognizer()
        gestureRecognizer.delegate = self
        gestureRecognizer.addTarget(self, action: #selector(self.onPanned(gestureRecognizer:)))
        return gestureRecognizer
    }()
    
    private var initialRotation: CGFloat = 0.0
    private var initialScale: CGFloat = 1.0
    private var initialTranslation: CGPoint = CGPoint.zero
    
    // MARK: - Public Functions
    
    public func addGestureRecognizers(to view: UIView) {
        view.addGestureRecognizer(pinchTransformGestureRecognizer)
        view.addGestureRecognizer(rotationTransformGestureRecognizer)
        view.addGestureRecognizer(panTransformGestureRecognizer)
    }
    
    // MARK: - Private Functions
    
    @objc
    private func onRotated(gestureRecognizer: UIRotationGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            initialRotation = state.rotation
        case .changed:
            let rotation = initialRotation + gestureRecognizer.rotation
            state.rotation = delegate?.normalizedRotation(for: rotation) ?? rotation
        case .ended:
            let rotation = initialRotation + gestureRecognizer.rotation
            state.rotation = delegate?.normalizedRotation(for: rotation) ?? rotation
        case .failed, .cancelled, .possible:
            break
        }
    }
    
    @objc
    private func onPinched(gestureRecognizer: UIPinchGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            initialScale = state.scale
        case .changed:
            let targetScale = initialScale * gestureRecognizer.scale
            state.scale = delegate?.normalizedScale(for: targetScale) ?? targetScale
        case .ended:
            let targetScale = initialScale * gestureRecognizer.scale
            state.scale = delegate?.normalizedScale(for: targetScale) ?? targetScale
        case .failed, .cancelled, .possible:
            break
        }
    }
    
    @objc
    private func onPanned(gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            initialTranslation = state.translation
        case .changed:
            let gestureTranslation = gestureRecognizer.translation(in: gestureRecognizer.view)
            let translation = CGPoint(x: initialTranslation.x + gestureTranslation.x, y: initialTranslation.y + gestureTranslation.y)
            state.translation = delegate?.normalizedTranslation(for: translation) ?? translation
        case .ended:
            let gestureTranslation = gestureRecognizer.translation(in: gestureRecognizer.view)
            let translation = CGPoint(x: initialTranslation.x + gestureTranslation.x, y: initialTranslation.y + gestureTranslation.y)
            state.translation = delegate?.normalizedTranslation(for: translation) ?? translation
        case .failed, .cancelled, .possible:
            break
        }
    }
}

extension TransformStateManager: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
