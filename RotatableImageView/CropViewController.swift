//
//  ViewController.swift
//  RotatableImageView
//
//  Created by ST20591 on 2017/10/25.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import UIKit

public class CropViewController: UIViewController {
    
    private static let dimViewColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.9)
    
    private lazy var imageView: RotatableImageView = {
        let imageView = RotatableImageView()
        imageView.image = #imageLiteral(resourceName: "sample.png")
        imageView.state.scale = 0.1
        return imageView
    }()
    
    private(set) lazy var gridView: GridView = {
        let gridView = GridView()
        gridView.backgroundColor = .clear
        gridView.layer.borderColor = UIColor.white.cgColor
        gridView.layer.borderWidth = 2.0
        gridView.isUserInteractionEnabled = false
        return gridView
    }()
    
    private lazy var holedDimView: UIView = {
        let dimView = UIView()
        dimView.isUserInteractionEnabled = false
        dimView.backgroundColor = CropViewController.dimViewColor
        return dimView
    }()
    
    private lazy var holeMaskView: UIView = {
        let maskView = UIView()
        maskView.isHidden = true
        maskView.isUserInteractionEnabled = false
        maskView.backgroundColor = CropViewController.dimViewColor
        return maskView
    }()
    
    public var maskImage: UIImage? {
        didSet {
            if let maskImage = maskImage?.blacked(inverse: true) {
                holeMaskView.mask(image: maskImage)
                holeMaskView.isHidden = false
            } else {
                holeMaskView.isHidden = true
            }
        }
    }
    
    public var cropRect: CGRect = CGRect.zero {
        didSet {
            gridView.frame = cropRect
            holeMaskView.frame = cropRect
            holedDimView.mask(rect: cropRect, inverse: true)
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        
        view.addSubview(imageView)
        view.addSubview(holedDimView)
        view.addSubview(holeMaskView)
        view.addSubview(gridView)
        
        imageView.frame = view.bounds
        holedDimView.frame = view.bounds
        
        // Set sample crop rect
        cropRect = CGRect(origin: CGPoint(x: imageView.bounds.midX - 100, y: imageView.bounds.midY - 100), size: CGSize(width: 200, height: 200))
        
        // Set sample crop mask
        maskImage = UIImage.circle(size: cropRect.size, color: .black, backgroundColor: .white)
        
        adjustImageScaleToFitCropRect()
    }
    
    /// Adjusts scale of image to fit CropRect
    public func adjustImageScaleToFitCropRect() {
        imageView.adjustScaleToFit(cropRect)
    }
    
    /// Adjusts scale of image to fill CropRect
    public func adjustImageScaleToFillCropRect() {
        imageView.adjustScaleToFill(cropRect)
    }
    
    /// Get the image which is cropped with cropRect and masked with maskImage if needed.
    ///
    /// - returns: The cropped and masked image
    public func crop() -> UIImage? {
        guard let result = imageView.getImage(of: cropRect) else {
            return nil
        }
        if let mask = maskImage {
            return result.masked(with: mask)
        } else {
            return result
        }
    }
}
