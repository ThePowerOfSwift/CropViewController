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
    
    // MARK: - Public properties
    
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
    
    // MARK: - Private properties
    
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
    
    private var maskImage: UIImage? {
        didSet {
            if let maskImage = maskImage?.blacked(inverse: true) {
                holeMaskView.mask(image: maskImage)
                holeMaskView.isHidden = false
            } else {
                holeMaskView.isHidden = true
            }
        }
    }
    
    private var _cropPath: UIBezierPath = UIBezierPath() {
        didSet {
            _layoutWithCropPath()
        }
    }
    
    // MARK: - Lifecyle

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
        _layoutWithCropPath()
    }
    
    // MARK: - Public methods
    
    /// Set cropPath with UIBezierPath.
    ///
    /// - parameter path: Path to crop inside
    public func setCropPath(_ path: UIBezierPath) {
        _cropPath = path
        gridView.isHidden = true
    }
    
    /// Set cropPath with CGRect, and set maskImage if needed.
    ///
    /// - parameter rect: Path to crop inside
    /// - parameter mask: MaskImage to mask cropped image
    public func setCropPathWithRect(_ rect: CGRect, mask: UIImage? = nil) {
        _cropPath = UIBezierPath(rect: rect)
        gridView.isHidden = mask != nil
        gridView.frame = rect
        holeMaskView.frame = rect
        // Must be set after frame of holeMaskView was set.
        maskImage = mask
    }
    
    /// Adjusts scale of image to fill CropRect
    public func adjustImageScaleToFillCropRect() {
        imageView.adjustScaleToFill(_cropPath.bounds)
    }
    
    /// Get the image which is cropped with cropRect and masked with maskImage if needed.
    ///
    /// - returns: The cropped and masked image
    public func crop() -> UIImage? {
        guard let result = imageView.getCroppedImage(with: _cropPath) else {
            return nil
        }
        if let mask = maskImage {
            return result.masked(with: mask)
        } else {
            return result
        }
    }
    
    // MARK: - Private methods
    
    private func _layoutWithCropPath() {
        holedDimView.mask(path: _cropPath, inverse: true)
    }
    
    @objc
    private func onCropButtonTapped(_ button: UIButton) {
        let croppedImage = self.crop()
        delegate?.cropViewController(didImageCropped: self, croppedImage: croppedImage)
        self.dismiss(animated: true, completion: nil)
    }
}
