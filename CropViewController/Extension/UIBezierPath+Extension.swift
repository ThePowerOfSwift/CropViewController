//
//  UIBezierPath+Extension.swift
//  CropViewController
//
//  Created by ST20591 on 2017/10/31.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import UIKit

extension UIBezierPath {
    func duplicated() -> UIBezierPath {
        return cgPath.copy().map { UIBezierPath(cgPath: $0) } ?? UIBezierPath()
    }
    
    func transformed(with transform: CGAffineTransform) -> UIBezierPath {
        let pathCopy = duplicated()
        pathCopy.apply(transform)
        return pathCopy
    }
    
    func scaled(by scale: CGFloat) -> UIBezierPath? {
        return transformed(with: CGAffineTransform(scaleX: scale, y: scale))
    }
}
