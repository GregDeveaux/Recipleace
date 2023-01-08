//
//  UIButton+setupWithAccessibility.swift
//  Reciplease
//
//  Created by Greg-Mini on 01/01/2023.
//

import UIKit

extension UIButton {
    static func setupButton(title: String, color: UIColor, image: String, accessibilityMessage: String) -> UIButton { 
        let loginButton = UIButton()
        loginButton.configuration = .tinted()
        loginButton.configuration?.baseBackgroundColor = color
        loginButton.configuration?.baseForegroundColor = color
        loginButton.configuration?.cornerStyle = .dynamic

        loginButton.configuration?.image = UIImage(systemName: image)
        loginButton.configuration?.imagePadding = 6
        loginButton.configuration?.title = title

        let transformer = UIConfigurationTextAttributesTransformer { listTransform in
            var fontTransform = listTransform
            fontTransform.font = UIFont.boldSystemFont(ofSize: 20)
            return fontTransform
        }
        loginButton.configuration?.titleTextAttributesTransformer = transformer

        loginButton.isAccessibilityElement = true
        loginButton.accessibilityTraits = .button
        loginButton.accessibilityHint = accessibilityMessage

        return loginButton
    }
}
