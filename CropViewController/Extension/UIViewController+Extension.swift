//
//  UIViewController+Extension.swift
//  CropViewController
//
//  Created by ST20591 on 2017/10/31.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import UIKit

extension UIViewController {
    func layoutAsBottomView(_ bottomView: UIView, height: CGFloat = 60) {
        if let bottomSuperView = bottomView.superview {
            if bottomSuperView != view {
                bottomView.removeFromSuperview()
                view.addSubview(bottomView)
            }
        } else {
            view.addSubview(bottomView)
        }
        
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        if let window = UIApplication.shared.windows.first, window.safeAreaInsets.bottom > 0.0 {
            // Temporary value
            bottomView.frame = CGRect(x: 8, y: view.bounds.height - height, width: view.bounds.width - 16, height: height)
            NSLayoutConstraint.activate([
                bottomView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                bottomView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8),
                bottomView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8),
                bottomView.heightAnchor.constraint(equalToConstant: height)
                ])
            bottomView.layer.cornerRadius = 10
            bottomView.layer.shadowColor = UIColor.black.cgColor
            bottomView.layer.shadowOpacity = 0.5
            bottomView.layer.shadowOffset = CGSize(width: 2, height: 2)
        } else {
            NSLayoutConstraint.activate([
                bottomView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                bottomView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
                bottomView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
                bottomView.heightAnchor.constraint(equalToConstant: height)
                ])
        }
    }
}
