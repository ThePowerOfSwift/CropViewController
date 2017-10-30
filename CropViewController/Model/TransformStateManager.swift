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
    func onStateChanged(_ state: TransformState)
}

struct TransformState {
    var rotation: CGFloat = 0.0
    var scale: CGFloat = 1.0
    var translation: CGPoint = CGPoint.zero
    
    static let identity = TransformState()
}

class TransformStateManager: NSObject {
    private lazy var pinchGestureRecognizer: UIPinchGestureRecognizer = {
        let gestureRecognizer = UIPinchGestureRecognizer()
        gestureRecognizer.delegate = self
        gestureRecognizer.addTarget(self, action: #selector(self.onPinched(gestureRecognizer:)))
        return gestureRecognizer
    }()
    
    private lazy var rotationGestureRecognizer: UIRotationGestureRecognizer = {
        let gestureRecognizer = UIRotationGestureRecognizer()
        gestureRecognizer.delegate = self
        gestureRecognizer.addTarget(self, action: #selector(self.onRotated(gestureRecognizer:)))
        return gestureRecognizer
    }()
    
    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let gestureRecognizer = UIPanGestureRecognizer()
        gestureRecognizer.delegate = self
        gestureRecognizer.addTarget(self, action: #selector(self.onPanned(gestureRecognizer:)))
        return gestureRecognizer
    }()
    
    private var initialRotation: CGFloat = 0.0
    private var initialScale: CGFloat = 1.0
    private var initialTranslation: CGPoint = CGPoint.zero
    
    weak var delegate: TransformStateManagerDelegate?
    
    var state = TransformState() {
        didSet {
            delegate?.onStateChanged(state)
        }
    }
    
    func setupGestureRecognizers(on view: UIView) {
        view.addGestureRecognizer(pinchGestureRecognizer)
        view.addGestureRecognizer(rotationGestureRecognizer)
        view.addGestureRecognizer(panGestureRecognizer)
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
            let targetScale = initialScale * gestureRecognizer.scale
            state.scale = delegate?.normalizedScale(for: targetScale) ?? targetScale
        case .ended:
            let targetScale = initialScale * gestureRecognizer.scale
            state.scale = delegate?.normalizedScale(for: targetScale) ?? targetScale
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
