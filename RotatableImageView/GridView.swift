//
//  GridView.swift
//  ha1f-crop
//
//  Created by ST20591 on 2017/10/18.
//  Copyright © 2017年 ha1f. All rights reserved.
//
import UIKit

struct GridConfiguration {
    var xRatios: [CGFloat] = [1, 1, 1]
    var yRatios: [CGFloat] = [1, 1, 1]
    var showDiagonal: Bool = true
    
    static func equalRatio(verticalBlocksCount: Int,
                           horizontalBlocksCount: Int,
                           showDiagonal: Bool = false) -> GridConfiguration {
        return GridConfiguration(
            xRatios: (0..<horizontalBlocksCount).map { _ in 1 },
            yRatios: (0..<verticalBlocksCount).map { _ in 1 },
            showDiagonal: showDiagonal)
    }
    
    static let ruleOfThirds = GridConfiguration.equalRatio(
        verticalBlocksCount: 3, horizontalBlocksCount: 3, showDiagonal: false)
    static let cross = GridConfiguration.equalRatio(verticalBlocksCount: 2,
                                                    horizontalBlocksCount: 2,
                                                    showDiagonal: false)
    static let slantedCross = GridConfiguration.equalRatio(verticalBlocksCount: 1,
                                                           horizontalBlocksCount: 1,
                                                           showDiagonal: true)
    static let railman = GridConfiguration.equalRatio(verticalBlocksCount: 1,
                                                      horizontalBlocksCount: 4,
                                                      showDiagonal: true)
    
    private static func _distributedValues(value: CGFloat, ratios: [CGFloat]) -> [CGFloat] {
        let sum = ratios.reduce(0, +)
        var currentValue: CGFloat = 0
        return ratios.map { ratio in
            currentValue += ratio
            return value * currentValue / sum
        }
    }
    
    func xValues(width: CGFloat) -> [CGFloat] {
        return GridConfiguration._distributedValues(value: width, ratios: xRatios)
    }
    
    func yValues(height: CGFloat) -> [CGFloat] {
        return GridConfiguration._distributedValues(value: height, ratios: yRatios)
    }
}

struct GridViewAppearanceConfiguration {
    /// The color of grid
    var gridColor: UIColor = UIColor(displayP3Red: 0.8, green: 0.8, blue: 0.8, alpha: 0.8)
    
    /// The color of border
    var borderColor: UIColor? = .white
    
    /// The width of border
    var borderWidth: CGFloat = 1
}

class GridView: UIView {
    
    // MARK: Properties
    
    var appearanceConfig = GridViewAppearanceConfiguration() {
        didSet {
            _updateAppearance()
        }
    }
    
    var config: GridConfiguration = GridConfiguration.ruleOfThirds {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // MARK: Initializers
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setup()
    }
    
    // MARK: Methods
    
    private func _setup() {
        backgroundColor = .clear
        _updateAppearance()
    }
    
    private func _updateAppearance() {
        layer.borderColor = appearanceConfig.borderColor?.cgColor
        layer.borderWidth = appearanceConfig.borderWidth
        layer.setNeedsDisplay()
    }
    
    /// The default implementation of draw(_:) does nothing,
    /// so thre is no need to call super.draw(_:)
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        context.clear(self.bounds)
        
        context.setLineWidth(1)
        context.setStrokeColor(appearanceConfig.gridColor.cgColor)
        
        // 縦線
        let xValues = config.xValues(width: CGFloat(bounds.width))
        xValues.forEach { xValue in
            context.addLines(between: [
                CGPoint(x: xValue, y: 0),
                CGPoint(x: xValue, y: bounds.height)])
        }
        
        // 横線
        let yValues = config.yValues(height: CGFloat(bounds.height))
        yValues.forEach { yValue in
            context.addLines(between: [
                CGPoint(x: 0, y: yValue),
                CGPoint(x: bounds.width, y: yValue)])
        }
        
        // 対角線
        if config.showDiagonal {
            context.move(to: CGPoint(x: 0, y: 0))
            context.addLine(to: CGPoint(x:CGFloat(bounds.width), y: CGFloat(bounds.height)))
            
            context.move(to: CGPoint(x: CGFloat(bounds.width), y: 0))
            context.addLine(to: CGPoint(x: 0, y: CGFloat(bounds.height)))
        }
        
        context.strokePath()
    }
}
