//
//  CGSize+Extension.swift
//  CropViewController
//
//  Created by ST20591 on 2017/11/10.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import UIKit

extension CGSize {
    func scaled(by scale: CGFloat) -> CGSize {
        return CGSize(width: width * scale, height: height * scale)
    }
    
    private func _scaleFitScales(to otherSize: CGSize) -> (widthScale: CGFloat, heightScale: CGFloat) {
        let widthScale = self.width != 0 ? (otherSize.width / self.width) : 0
        let heightScale = self.height != 0 ? (otherSize.height / self.height) : 0
        return (widthScale: widthScale, heightScale: heightScale)
    }
    
    func aspectFillScale(to otherSize: CGSize) -> CGFloat {
        let scales = _scaleFitScales(to: otherSize)
        return max(scales.widthScale, scales.heightScale)
    }
    
    func aspectFitScale(to otherSize: CGSize) -> CGFloat {
        let scales = _scaleFitScales(to: otherSize)
        return min(scales.widthScale, scales.heightScale)
    }
    
    func aspectFit(to otherSize: CGSize) -> CGSize {
        return self.scaled(by: aspectFitScale(to: otherSize))
    }
    
    func aspectFill(to otherSize: CGSize) -> CGSize {
        return self.scaled(by: aspectFillScale(to: otherSize))
    }
}
