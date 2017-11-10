//
//  CGPoint+Extension.swift
//  CropViewController
//
//  Created by ST20591 on 2017/11/10.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import UIKit

extension CGPoint {
    func relativePoint(from origin: CGPoint) -> CGPoint {
        return CGPoint(x: x - origin.x, y: y - origin.y)
    }
}
