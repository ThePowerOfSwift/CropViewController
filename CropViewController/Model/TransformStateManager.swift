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

private class DefaultTransformStateManagerDelegate: TransformStateManagerDelegate { }

final class TransformStateManager: NSObject {
    
    // MARK: - Public Properties
    
    public weak var delegate: TransformStateManagerDelegate?
    
    public var state = TransformState() {
        didSet {
            delegate?.onStateChanged(state)
        }
    }
    
    // MARK: - Private Properties
    
    private(set) lazy var pinchTransformGestureRecognizer: UIPinchGestureRecognizer = {
        let gestureRecognizer = UIPinchGestureRecognizer()
        gestureRecognizer.delegate = self
        gestureRecognizer.addTarget(self, action: #selector(self.onPinched(gestureRecognizer:)))
        return gestureRecognizer
    }()
    
    private(set) lazy var rotationTransformGestureRecognizer: UIRotationGestureRecognizer = {
        let gestureRecognizer = UIRotationGestureRecognizer()
        gestureRecognizer.delegate = self
        gestureRecognizer.addTarget(self, action: #selector(self.onRotated(gestureRecognizer:)))
        return gestureRecognizer
    }()
    
    private(set) lazy var panTransformGestureRecognizer: UIPanGestureRecognizer = {
        let gestureRecognizer = UIPanGestureRecognizer()
        gestureRecognizer.delegate = self
        gestureRecognizer.addTarget(self, action: #selector(self.onPanned(gestureRecognizer:)))
        return gestureRecognizer
    }()
    
    private var strongDelegate: TransformStateManagerDelegate {
        return delegate ?? DefaultTransformStateManagerDelegate()
    }
    
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
        case .began, .changed, .ended:
            let oldRotation = state.rotation
            let modifiedRotation = state.rotation + gestureRecognizer.rotation
            let targetRotation = strongDelegate.normalizedRotation(for: modifiedRotation)
            let actualGestureRotation = targetRotation - oldRotation
            
            // relative point from center of gesture.view
            let touchOrigin = gestureRecognizer.view
                .map { gestureRecognizer.location(in: $0).relativePoint(from: $0.center) }
                ?? CGPoint.zero
            // Rotate center point with "rotating center = touchOrigin"
            let transform = CGAffineTransform(translationX: -touchOrigin.x, y: -touchOrigin.y)
                .rotated(by: actualGestureRotation)
                .translatedBy(x: touchOrigin.x, y: touchOrigin.y)
            let modifiedTranslation = state.translation.applying(transform)
            let targetTranslation = strongDelegate.normalizedTranslation(for: modifiedTranslation)
            
            // translationが実現可能なときのみ実行
            if modifiedTranslation == targetTranslation {
                state.rotation = targetRotation
                state.translation = targetTranslation
            }
            
            gestureRecognizer.rotation = 0.0
        case .failed, .cancelled, .possible:
            break
        }
    }
    
    @objc
    private func onPinched(gestureRecognizer: UIPinchGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began, .changed, .ended:
            let oldScale = state.scale
            let modifiedScale = state.scale * gestureRecognizer.scale
            let targetScale = strongDelegate.normalizedScale(for: modifiedScale)
            let actualGestureScale = oldScale != 0 ? targetScale / oldScale : gestureRecognizer.scale
            
            let transform =  CGAffineTransform(scaleX: actualGestureScale, y: actualGestureScale)
            let modifiedTranslation = state.translation.applying(transform)
            let targetTranslation = strongDelegate.normalizedTranslation(for: modifiedTranslation)
            
            // translationが実現可能なときのみ実行
            if modifiedTranslation == targetTranslation {
                state.scale = targetScale
                state.translation = targetTranslation
            }
            
            gestureRecognizer.scale = 1.0
        case .failed, .cancelled, .possible:
            break
        }
    }
    
    @objc
    private func onPanned(gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began, .changed, .ended:
            let gestureTranslation = gestureRecognizer.translation(in: gestureRecognizer.view)
            let translation = CGPoint(x: state.translation.x + gestureTranslation.x, y: state.translation.y + gestureTranslation.y)
            state.translation = strongDelegate.normalizedTranslation(for: translation)
            gestureRecognizer.setTranslation(.zero, in: gestureRecognizer.view)
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
