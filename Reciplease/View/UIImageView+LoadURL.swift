//
//  UIImageView+LoadUrl.swift
//  Reciplease
//
//  Created by Greg-Mini on 29/12/2022.
//

import UIKit

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.image = image
                    }
                }
            }
        }
    }

    func maskImageView(for imageView: UIImageView) {
        let mask = CAGradientLayer()
        mask.colors = [UIColor.clear.cgColor, UIColor.white.cgColor, UIColor.white.cgColor]
        mask.startPoint = CGPoint(x: 0, y: 0.5)
        mask.endPoint = CGPoint(x: 1, y: 0.5)
        mask.locations = [0, 0.2, 1]
        mask.frame = imageView.bounds
        imageView.layer.mask = mask
    }
}
