//
//  UIImage+Extension.swift
//  RotatableImageView
//
//  Created by ST20591 on 2017/10/27.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import UIKit

extension UIImage {
    
    /// Get as CIImage
    /// If the UIImage is build from CGImage, ciImage is nil.
    /// https://developer.apple.com/documentation/uikit/uiimage/1624129-ciimage
    /// If so, we must build by CIImage(image:_).
    var safeCiImage: CIImage? {
        return self.ciImage ?? CIImage(image: self)
    }
    
    /// Get as CGImage
    /// If the UIImage is build from CIImage, cgImage is nil.
    /// https://developer.apple.com/documentation/uikit/uiimage/1624147-cgimage
    /// If so, we must build with CIContext
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
    
    /// Create UIImage by drawing current image on colored context.
    ///
    /// - parameter color: Color of the background context
    ///
    /// - returns: The created image. Nil on error.
    func withSettingBackground(color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        defer {
            UIGraphicsEndImageContext()
        }
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        guard let cgImage = safeCgImage else {
            return nil
        }
        let frame = CGRect(origin: .zero, size: size)
        context.clear(frame)
        context.setFillColor(color.cgColor)
        context.fill(frame)
        context.draw(cgImage, in: frame)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    /// Create UIImage of black or transparent.
    /// CIImage-masking treats white as transparent, while CALayer-masking
    /// treats transparent as transparent.
    /// For this reason, we should make white of UIImage transparent to use
    /// the CIImage-masking image for CALayer-masking image.
    ///
    /// - parameter inverse: Invert transparent area or not
    ///
    /// - returns: The created image. Nil on error.
    func blacked(inverse: Bool = false) -> UIImage? {
        if inverse {
            guard let mask = UIImage.empty(size: size, color: .white)?.masked(with: self)?.withSettingBackground(color: .black) else {
                return nil
            }
            return UIImage.empty(size: size, color: .black)?.masked(with: mask)
        } else {
            return UIImage.empty(size: size, color: .black)?.masked(with: self)
        }
    }
    
    /// Create UIImage by masking current image with another image.
    /// Treat white as transparent.
    ///
    /// - parameter image: Image for masking
    ///
    /// - returns: The created image. Nil on error.
    func masked(with image: UIImage) -> UIImage? {
        guard let maskRef = image.safeCgImage,
            let ref = safeCgImage,
            let dataProvider = maskRef.dataProvider else {
                return nil
        }
        
        let mask = CGImage(maskWidth: maskRef.width,
                           height: maskRef.height,
                           bitsPerComponent: maskRef.bitsPerComponent,
                           bitsPerPixel: maskRef.bitsPerPixel,
                           bytesPerRow: maskRef.bytesPerRow,
                           provider: dataProvider,
                           decode: nil,
                           shouldInterpolate: false)
        return mask
            .flatMap { ref.masking($0) }
            .map { UIImage(cgImage: $0) }
    }
    
    /// Create UIImage filled with a color.
    ///
    /// - parameter size: Size of output image
    /// - parameter color: Color to fill
    ///
    /// - returns: The created image. Nil on error.
    static func empty(size: CGSize, color: UIColor = .clear) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, true, UIScreen.main.scale)
        defer {
            UIGraphicsEndImageContext()
        }
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        let frame = CGRect(origin: .zero, size: size)
        context.clear(frame)
        context.setFillColor(color.cgColor)
        context.fill(frame)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    /// Create UIImage of circle.
    ///
    /// - parameter size: Size of output image
    /// - parameter color: Color of the circle
    /// - parameter backgroundColor: Background color of the image
    ///
    /// - returns: The created image. Nil on error.
    static func circle(size: CGSize, color: UIColor, backgroundColor: UIColor = .clear) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, true, UIScreen.main.scale)
        defer {
            UIGraphicsEndImageContext()
        }
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        let frame = CGRect(origin: .zero, size: size)
        context.clear(frame)
        
        // background
        context.setFillColor(backgroundColor.cgColor)
        context.fill(frame)
        
        // circle
        context.setFillColor(color.cgColor)
        context.setLineWidth(0)
        context.addEllipse(in: frame)
        context.fillPath()
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
