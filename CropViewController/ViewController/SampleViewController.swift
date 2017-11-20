//
//  SampleViewController.swift
//  CropViewController
//
//  Created by ST20591 on 2017/10/31.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import UIKit

class SampleViewController: UIViewController {
    
    private lazy var startButton: UIButton = {
        let startButton = UIButton()
        startButton.backgroundColor = UIColor.orange
        startButton.setTitle("START!", for: .normal)
        startButton.addTarget(self, action: #selector(self.cropImage), for: .touchUpInside)
        return startButton
    }()
    
    fileprivate lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 200),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        imageView.image = #imageLiteral(resourceName: "sample.png")
        
        view.addSubview(startButton)
        layoutAsBottomView(startButton)
    }
    
    @objc
    func cropImage() {
        let cropViewController = CropViewController()
        cropViewController.image = imageView.image
        
        let cropSize = CGSize(width: 300, height: 300)
        let cropRect = CGRect(origin: CGPoint(x: view.bounds.midX - cropSize.width / 2, y: view.bounds.midY - cropSize.height / 2), size: cropSize)
        
        // crop with path
        let cropPath = UIBezierPath(roundedRect: cropRect, cornerRadius: cropRect.width / 4)
        cropViewController.setCropPath(cropPath)
        
//        // crop with rect + mask
//        let maskImage = UIImage.circle(size: cropRect.size, color: .black, backgroundColor: .white)
//        cropViewController.setCropPathWithRect(cropRect, mask: maskImage)
        
        cropViewController.delegate = self
        cropViewController.showCropButton = true
        cropViewController.modalTransitionStyle = .crossDissolve
        
        self.present(cropViewController, animated: true, completion: nil)
    }
    
}

extension SampleViewController: CropViewControllerDelegate {
    func cropViewController(didImageCropped cropViewController: CropViewController, croppedImage: UIImage?) {
        imageView.image = croppedImage
    }
}
