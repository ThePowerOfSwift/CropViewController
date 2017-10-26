//
//  ViewController.swift
//  RotatableImageView
//
//  Created by ST20591 on 2017/10/25.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import UIKit

extension CGRect {
    func withCentering(in rect: CGRect) -> CGRect {
        let center = CGPoint(x: (rect.width - width) / 2, y: (rect.height - height) / 2)
        return CGRect(origin: center, size: size)
    }
}

extension UIImage {
    var safeCiImage: CIImage? {
        return self.ciImage ?? CIImage(image: self)
    }
    
    var safeCgImage: CGImage? {
        if let cgImge = self.cgImage {
            return cgImge
        }
        if let ciImage = safeCiImage {
            let context = CIContext(options: nil)
            return context.createCGImage(ciImage, from: ciImage.extent)
        }
        return nil
    }
}

/// 中心に画像を描画する
/// TODO: automatic scale on setting image
class RotatableImageView: UIView {
    var image: UIImage? {
        didSet {
            setNeedsDisplay()
        }
    }
    var angle: CGFloat = 0.0
    var scale: CGFloat = 1.0
    var translateX: CGFloat = 0.0
    var translateY: CGFloat = 0.0
    
    var contentSize: CGSize {
        return image?.size ?? .zero
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _commonInit()
    }
    
    private func _commonInit() {
        self.backgroundColor = .clear
    }
    
    override func sizeToFit() {
        self.frame = CGRect(origin: self.frame.origin, size: contentSize)
    }
    
    /// draw scale = 1.0 image and crop with converted rect.
    func getImage(of frame: CGRect) -> UIImage? {
        let drawScale = 1 / scale
        
        let drawRect = CGRect(x: 0, y: 0, width: bounds.size.width * drawScale, height: bounds.size.height * drawScale)
        
        UIGraphicsBeginImageContext(drawRect.size)
        defer {
            UIGraphicsEndImageContext()
        }
        guard let context = _draw(drawRect, drawScale: drawScale) else {
            return nil
        }
        let convertedFrame = CGRect(x: frame.minX * drawScale, y: frame.minY * drawScale, width: frame.width * drawScale, height: frame.width * drawScale)
        return context.makeImage()?.cropping(to: convertedFrame).map { UIImage(cgImage: $0) }
    }
    
    @discardableResult
    private func _draw(_ rect: CGRect, drawScale: CGFloat = 1.0) -> CGContext? {
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        guard let image = image else {
            return context
        }
        
        // clear
        context.clear(rect)
        
        // background
        context.setFillColor((backgroundColor ?? UIColor.clear).cgColor)
        context.fill(rect)
        
        // 座標系を一時退避
        context.saveGState()
        
        // 座標系を中心に
        context.translateBy(x: rect.midX, y: rect.midY)
        
        // translate
        context.translateBy(x: translateX * drawScale, y: translateY * drawScale)
        
        let imageFrame = CGRect(origin: .zero, size: image.size)
        
        // rotate
        context.rotate(by: angle)
        
        // scale
        context.scaleBy(x: scale * drawScale, y: scale * drawScale)
        
        // draw
        image.draw(in: imageFrame.offsetBy(dx: -imageFrame.width / 2, dy: -imageFrame.width / 2))
        
        // 座標系を戻す
        context.restoreGState()
        
        return context
    }
    
    override func draw(_ rect: CGRect) {
        _draw(rect)
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let imageView = RotatableImageView(frame: view.bounds)
        imageView.image = #imageLiteral(resourceName: "sample.png")
        imageView.scale = 1.5
        imageView.angle = CGFloat.pi / 3 * 2
        view.addSubview(imageView)
        
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) {  _ in
            imageView.image = imageView.getImage(of: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)).withCentering(in: imageView.bounds))
            imageView.scale = 1.5
            imageView.angle = 0
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

