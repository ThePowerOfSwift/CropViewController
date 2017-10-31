//
//  TransformState.swift
//  CropViewController
//
//  Created by ST20591 on 2017/10/31.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import UIKit

public struct TransformState {
    var rotation: CGFloat = 0.0
    var scale: CGFloat = 1.0
    var translation: CGPoint = CGPoint.zero
    
    static let identity = TransformState()
}
