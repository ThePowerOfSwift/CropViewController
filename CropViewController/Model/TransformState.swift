//
//  TransformState.swift
//  CropViewController
//
//  Created by ST20591 on 2017/10/31.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import UIKit

private extension CGPoint {
    static func innerProduct(_ lPoint: CGPoint, _ rPoint: CGPoint) -> CGFloat {
        return lPoint.x * rPoint.x + lPoint.y * rPoint.y
    }
    var length: CGFloat {
        return sqrt(pow(x, 2) + pow(y, 2))
    }
    
    /// Gradient of the vector.
    /// Even if x = 0, this does not crashes and returns CGFloat.pi / 2
    var gradient: CGFloat {
        return atan(y / x)
    }
}



public struct TransformState {
    var rotation: CGFloat = 0.0
    var scale: CGFloat = 1.0
    var translation: CGPoint = CGPoint.zero
    
    static func from(transform: CGAffineTransform) -> TransformState {
        let translation = CGPoint(x: transform.tx, y: transform.ty)
        
        let transformWithoutTranslation = transform.concatenating(CGAffineTransform(translationX: -translation.x, y: -translation.y))
        
        let xTransformed = CGPoint(x: 1, y: 0).applying(transformWithoutTranslation)
        let yTransformed = CGPoint(x: 0, y: 1).applying(transformWithoutTranslation)
        
        // check if transformed unit vector
        let innerProduct = CGPoint.innerProduct(xTransformed, yTransformed)
        guard innerProduct == 0 else {
            fatalError("must not be distorted. Inner product was \(innerProduct)")
        }
        let rotation = xTransformed.gradient
        
        let scaleX = xTransformed.length
        let scaleY = yTransformed.length
        guard scaleX == scaleY else {
            fatalError("must not change aspect ratio")
        }
        
        return TransformState(rotation: rotation, scale: scaleX, translation: translation)
    }
    
    func asCGAffineTransform() -> CGAffineTransform {
        return CGAffineTransform(translationX: translation.x, y: translation.y)
            .rotated(by: rotation)
            .scaledBy(x: scale, y: scale)
    }
    
    static let identity = TransformState()
}

extension TransformState: Equatable {
    public static func ==(lhs: TransformState, rhs: TransformState) -> Bool {
        return lhs.rotation == rhs.rotation
            && lhs.scale == rhs.scale
            && lhs.translation == rhs.translation
    }
}
