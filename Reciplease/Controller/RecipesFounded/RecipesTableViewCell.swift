//
//  RecipesTableViewCell.swift
//  Reciplease
//
//  Created by Greg Deveaux on 26/12/2022.
//

import UIKit
import Firebase
import FirebaseStorage

class RecipesTableViewCell: UITableViewCell {

        // -------------------------------------------------------
        //MARK: - outlets
        // -------------------------------------------------------

    @IBOutlet weak var recipeImage: UIImageView! {
        didSet {
                /// accessibility
            recipeImage.isAccessibilityElement = true
            recipeImage.accessibilityTraits = .image
            recipeImage.accessibilityHint = "Image of the recipe"
        }
    }
    @IBOutlet weak var titleLabel: UILabel!  {
        didSet {
                /// accessibility
            titleLabel.isAccessibilityElement = true
            titleLabel.accessibilityTraits = .staticText
            titleLabel.accessibilityHint = "Title of the recipe"
        }
    }
    @IBOutlet weak var ingredientsLabel: UILabel! {
        didSet {
                /// accessibility
            ingredientsLabel.isAccessibilityElement = true
            ingredientsLabel.accessibilityTraits = .staticText
            ingredientsLabel.accessibilityHint = "Ingredients used"
        }
    }
    @IBOutlet weak var numberOfLikeLabel: UILabel! {
        didSet {
                /// accessibility
            numberOfLikeLabel.isAccessibilityElement = true
            numberOfLikeLabel.accessibilityTraits = .staticText
            numberOfLikeLabel.accessibilityHint = "Number of like to the community for this recipe"
        }
    }
    @IBOutlet weak var leafView: UIView! {
        didSet {
                /// design
            leafView.layer.cornerRadius = 20
            leafView.layer.masksToBounds = true

            leafView.layer.shadowColor = UIColor.black.cgColor
            leafView.layer.shadowOpacity = 0.3
            leafView.layer.shadowOffset = CGSize.zero
            leafView.layer.shadowRadius = 8
        }
    }

    @IBOutlet weak var favoriteButton: UIButton! {
        didSet {
                /// accessibility
            favoriteButton.isAccessibilityElement = true
            favoriteButton.accessibilityTraits = .button
            favoriteButton.accessibilityHint = "tapped to add the recipe in the favorites list"
        }
    }

    @IBAction func tappedFavorite(_ sender: Any) {
            // update with action button config
        favoriteButton.setNeedsUpdateConfiguration()
    }

}
