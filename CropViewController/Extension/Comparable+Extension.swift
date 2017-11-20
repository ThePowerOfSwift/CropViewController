//
//  Comparable+Extension.swift
//  CropViewController
//
//  Created by ST20591 on 2017/11/20.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import Foundation

extension Comparable {
    func clamp(min minValue: Self, max maxValue: Self) -> Self {
        return min(max(self, minValue), maxValue)
    }
}
