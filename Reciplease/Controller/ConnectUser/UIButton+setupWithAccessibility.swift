//
//  UIButton+setupWithAccessibility.swift
//  Reciplease
//
//  Created by Greg-Mini on 01/01/2023.
//

import UIKit

extension UIButton {
    static func setupButton(title: String, color: UIColor, accessibilityMessage: String) -> UIButton {
        let loginButton = UIButton(type: .system)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.backgroundColor = color
        loginButton.titleLabel?.font = .boldSystemFont(ofSize: 14)
        loginButton.setTitle(title, for: .normal)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.layer.cornerRadius = 5
        loginButton.isAccessibilityElement = true
        loginButton.accessibilityTraits = .button
        loginButton.accessibilityHint = accessibilityMessage
        return loginButton
    }
}
