//
//  ViewController.swift
//  CropViewController
//
//  Created by ST20591 on 2017/10/25.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import UIKit

public protocol CropViewControllerDelegate: class {
    func cropViewController(didImageCropped cropViewController: CropViewController, croppedImage: UIImage?)
}

public class CropViewController: UIViewController {
    
    private static let dimViewColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.9)
    
    public weak var delegate: CropViewControllerDelegate?
    
    public var image: UIImage? {
        set {
            imageView.image = newValue
        }
        get {
            return imageView.image
        }
    }
    
    public var showCropButton: Bool {
        set {
            cropButton.isHidden = showCropButton
        }
        get {
            return cropButton.isHidden
        }
    }
    
    private lazy var imageView: TransformableImageView = {
        let imageView = TransformableImageView()
        imageView.state.scale = 1.0
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
    
    private lazy var cropButton: UIButton = {
       let button = UIButton()
        button.backgroundColor = UIColor.darkGray
        button.addTarget(self, action: #selector(self.onCropButtonTapped(_:)), for: .touchUpInside)
        button.setTitle("CROP!", for: .normal)
        return button
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
            _layoutWithCropRect()
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        
        view.addSubview(imageView)
        view.addSubview(holedDimView)
        view.addSubview(holeMaskView)
        view.addSubview(gridView)
        view.addSubview(cropButton)
        
        imageView.frame = view.bounds
        holedDimView.frame = view.bounds
        layoutAsBottomView(cropButton, height: 60)
        
        adjustImageScaleToFillCropRect()
        
        // cropRect
        _layoutWithCropRect()
    }
    
    private func _layoutWithCropRect() {
        gridView.frame = cropRect
        holeMaskView.frame = cropRect
        holedDimView.mask(rect: cropRect, inverse: true)
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
    
    @objc
    private func onCropButtonTapped(_ button: UIButton) {
        let croppedImage = self.crop()
        delegate?.cropViewController(didImageCropped: self, croppedImage: croppedImage)
        self.dismiss(animated: true, completion: nil)
    }
}
