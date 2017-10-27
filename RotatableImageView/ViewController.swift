//
//  ViewController.swift
//  RotatableImageView
//
//  Created by ST20591 on 2017/10/25.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import UIKit

class CropViewController: UIViewController {
    
    private lazy var imageView: RotatableImageView = {
        let imageView = RotatableImageView()
        imageView.image = #imageLiteral(resourceName: "sample.png")
        imageView.state.scale = 0.1
        return imageView
    }()
    
    private lazy var gridView: GridView = {
        let gridView = GridView()
        gridView.backgroundColor = .clear
        gridView.layer.borderColor = UIColor.white.cgColor
        gridView.layer.borderWidth = 2.0
        gridView.isUserInteractionEnabled = false
        return gridView
    }()
    
    var cropRect: CGRect = CGRect.zero {
        didSet {
            imageView.adjustScaleToFit(cropRect)
            gridView.frame = cropRect
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        
        view.addSubview(imageView)
        view.addSubview(gridView)
        _setupButton()
        
        imageView.frame = view.bounds
        
        cropRect = CGRect(origin: CGPoint(x: imageView.bounds.midX - 100, y: imageView.bounds.midY - 100), size: CGSize(width: 200, height: 200))
    }
    
    private func _setupButton() {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        button.setTitle("CROP!", for: .normal)
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 50),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            button.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            button.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor)
            ])
        button.addTarget(self, action: #selector(self.onCropButtonTapped), for: .touchUpInside)
    }
    
    @objc func onCropButtonTapped() {
        if let result = crop() {
            imageView.image = result
            imageView.state.translation = .zero
            imageView.state.rotation = 0.0
        }
    }
    
    func crop() -> UIImage? {
        return imageView.getImage(of: cropRect)
    }
}
