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
}
