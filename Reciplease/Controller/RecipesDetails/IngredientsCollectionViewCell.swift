//
//  IngredientsCollectionViewCell.swift
//  Reciplease
//
//  Created by Greg Deveaux on 04/01/2023.
//

import UIKit

class IngredientsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var ingredientNameLabel: UILabel! {
        didSet {
                /// accessibility
            ingredientNameLabel.isAccessibilityElement = true
            ingredientNameLabel.accessibilityTraits = .staticText
            ingredientNameLabel.accessibilityHint = "name of the ingredient"
        }
    }
    @IBOutlet weak var ingredientImageView: UIImageView! {
        didSet {
            ingredientImageView.layer.cornerRadius = 10
                /// accessibility
            ingredientImageView.isAccessibilityElement = true
            ingredientImageView.accessibilityTraits = .image
            ingredientImageView.accessibilityHint = "image of the ingredient"
        }
    }
}
