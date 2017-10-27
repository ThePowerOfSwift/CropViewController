//
//  UIView+Extension.swift
//  RotatableImageView
//
//  Created by ST20591 on 2017/10/27.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import UIKit

extension UIView {
    func mask(path: UIBezierPath, fillRule: String = kCAFillRuleEvenOdd) {
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.fillColor = UIColor.black.cgColor
        maskLayer.fillRule = fillRule
        maskLayer.path = path.cgPath
        self.layer.mask = maskLayer
    }
    
    func mask(rect: CGRect, inverse: Bool = false) {
        let path = UIBezierPath(rect: rect)
        if inverse {
            path.append(UIBezierPath(rect: self.bounds))
        }
        self.mask(path: path, fillRule: kCAFillRuleEvenOdd)
    }
    
    func mask(image: UIImage) {
        let maskLayer = CALayer()
        maskLayer.frame = self.bounds
        maskLayer.contents = image.cgImage
        self.layer.mask = maskLayer
    }
}
