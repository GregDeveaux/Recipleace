//
//  UITextField+setupWithAccessibility.swift
//  Reciplease
//
//  Created by Greg Deveaux on 01/01/2023.
//

import UIKit

extension UITextField  {
        // configuration of TextFields
    static func setupTextFields(placeholder: String, isSecure: Bool, accessibilityMessage: String) -> UITextField {
        let myTextField = UITextField()
        myTextField.translatesAutoresizingMaskIntoConstraints = false
        myTextField.placeholder = placeholder
        myTextField.backgroundColor = .white
        myTextField.borderStyle = .roundedRect
        myTextField.font = .systemFont(ofSize: 14)
        
            /// secure characters for the password with dots
        if isSecure {
            myTextField.isSecureTextEntry = true
        }
            /// accessibility
        myTextField.isAccessibilityElement = true
        myTextField.accessibilityHint = accessibilityMessage
        return myTextField
    }
}
