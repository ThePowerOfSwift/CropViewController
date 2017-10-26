//
//  ViewController.swift
//  RotatableImageView
//
//  Created by ST20591 on 2017/10/25.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private lazy var imageView: RotatableImageView = {
        let imageView = RotatableImageView()
        imageView.image = #imageLiteral(resourceName: "sample.png")
        imageView.state.scale = 0.1
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        
        imageView.frame = view.bounds
        imageView.fitScale()
        view.addSubview(imageView)
        
        let sampleCropRect = CGRect(origin: CGPoint(x: imageView.bounds.midX - 100, y: imageView.bounds.midY - 100), size: CGSize(width: 200, height: 200))
        
        let cropView = UIView(frame: sampleCropRect)
        cropView.backgroundColor = .clear
        cropView.layer.borderColor = UIColor.white.cgColor
        cropView.layer.borderWidth = 2.0
        cropView.isUserInteractionEnabled = false
        view.addSubview(cropView)

        Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { [weak self] _ in
            self?.crop(sampleCropRect)
        }
    }
    
    func crop(_ rect: CGRect) {
        let image = imageView.getImage(of: rect)
        imageView.image = image
        imageView.state.translation = .zero
        imageView.state.rotation = 0.0
    }
}
