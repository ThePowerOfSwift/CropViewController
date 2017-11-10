//
//  CGPoint+Extension.swift
//  CropViewController
//
//  Created by ST20591 on 2017/11/10.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import UIKit

extension CGPoint {
    /// Calculate the CGPoint in relative coordinate.
    ///
    /// - parameter point: The point used for origin of new coordinate.
    ///
    /// - returns: Relative coordinate from origin point.
    func relativePoint(from origin: CGPoint) -> CGPoint {
        return CGPoint(x: x - origin.x, y: y - origin.y)
    }
}
