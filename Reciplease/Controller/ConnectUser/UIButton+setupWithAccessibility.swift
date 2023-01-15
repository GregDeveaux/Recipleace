//
//  UIButton+setupWithAccessibility.swift
//  Reciplease
//
//  Created by Greg-Mini on 01/01/2023.
//

import UIKit

extension UIButton {
        // setup which use the configuration button
    static func setupButton(style: UIButton.Configuration, title: String, colorText: UIColor, colorBackground: UIColor, image: String, accessibilityMessage: String, activity: Bool) -> UIButton {
        let button = UIButton()

            // modify appearance of the button
        var configuration = style
        configuration.baseBackgroundColor = colorBackground
        configuration.baseForegroundColor = colorText
        configuration.cornerStyle = .dynamic

            // add an image in the button with placement
        configuration.image = UIImage(systemName: image)
        configuration.imagePadding = 10
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(scale: .medium)
        configuration.imagePlacement = .trailing
        configuration.title = title

            // modify the font of the button
        let transformer = UIConfigurationTextAttributesTransformer { listTransform in
            var fontTransform = listTransform
            fontTransform.font = UIFont.boldSystemFont(ofSize: 20)
            return fontTransform
        }
        configuration.titleTextAttributesTransformer = transformer

        button.addAction(
            UIAction { _ in
                print(title)
            }, for: .touchUpInside)

        button.isAccessibilityElement = true
        button.accessibilityTraits = .button
        button.accessibilityHint = accessibilityMessage

        button.configurationUpdateHandler = { button in
            var configuration = button.configuration
            configuration?.showsActivityIndicator = activity
            configuration?.imagePlacement = activity ? .leading : . trailing
            button.configuration = configuration
        }

        button.configuration = configuration
        return button
    }
}
