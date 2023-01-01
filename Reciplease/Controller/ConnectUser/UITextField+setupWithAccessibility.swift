//
//  UITextField+setupWithAccessibility.swift
//  Reciplease
//
//  Created by Greg-Mini on 01/01/2023.
//

import UIKit

extension UITextField  {

    static func setupTextFields(placeholder: String, isSecure: Bool, accessibilityMessage: String) -> UITextField {
        let myTextField = UITextField()
        myTextField.translatesAutoresizingMaskIntoConstraints = false
        myTextField.placeholder = placeholder
        myTextField.backgroundColor = .white
        myTextField.borderStyle = .roundedRect
        myTextField.font = .systemFont(ofSize: 14)
        if isSecure {
            myTextField.isSecureTextEntry = true
        }
        myTextField.isAccessibilityElement = true
        myTextField.accessibilityHint = accessibilityMessage
        return myTextField
    }
}
