//
//  CGSize+Extension.swift
//  CropViewController
//
//  Created by ST20591 on 2017/11/10.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import UIKit

extension CGSize {
    /// Calculate the uniformly scaled size.
    ///
    /// - parameter scale: The scale to apply
    ///
    /// - returns: The calculated size
    func uniformlyScaled(by scale: CGFloat) -> CGSize {
        return CGSize(width: width * scale, height: height * scale)
    }
    
    /// Calculate the x/y scale to fit to another size.
    ///
    /// - parameter otherSize: The size which you want to fill.
    ///
    /// - returns: The calculated scale tuple with format (widthScale, heightScale)
    private func _scaleFitScales(to otherSize: CGSize) -> (widthScale: CGFloat, heightScale: CGFloat) {
        let widthScale = self.width != 0 ? (otherSize.width / self.width) : 0
        let heightScale = self.height != 0 ? (otherSize.height / self.height) : 0
        return (widthScale: widthScale, heightScale: heightScale)
    }
    
    /// Calculate the scale to fill another size with keeping own aspect ratio.
    ///
    /// - parameter otherSize: The size which you want to fill.
    ///
    /// - returns: The calculated scale
    func aspectFillScale(to otherSize: CGSize) -> CGFloat {
        let scales = _scaleFitScales(to: otherSize)
        return max(scales.widthScale, scales.heightScale)
    }
    
    /// Calculate the scale to fit to another size with keeping own aspect ratio.
    ///
    /// - parameter otherSize: The size to which you want to fit.
    ///
    /// - returns: The calculated scale
    func aspectFitScale(to otherSize: CGSize) -> CGFloat {
        let scales = _scaleFitScales(to: otherSize)
        return min(scales.widthScale, scales.heightScale)
    }
}
