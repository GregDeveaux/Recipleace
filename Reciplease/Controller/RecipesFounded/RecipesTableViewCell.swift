//
//  RecipesTableViewCell.swift
//  Reciplease
//
//  Created by Greg-Mini on 26/12/2022.
//

import UIKit
import Firebase
import FirebaseStorage

class RecipesTableViewCell: UITableViewCell {

        // -----------------------------------------
        // MARK: - properties
        // -----------------------------------------

    let databaseReference: DatabaseReference = Database.database().reference()
    var isFavorite = false

    private lazy var favoritesRecipesReferencePath: DatabaseReference? = {
        guard let userID = Auth.auth().currentUser?.uid else { return nil }
        print("✅ RECIPES_DETAIL_VC/USER: \(String(describing: userID))")

        let favoritesRecipesReferencePath = databaseReference.child("users/\(userID)/favoritesRecipes")
        return favoritesRecipesReferencePath
    }()


        // -----------------------------------------
        //MARK: - outlets
        // -----------------------------------------

    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ingredientsLabel: UILabel!
    @IBOutlet weak var numberOfLikeLabel: UILabel!
    @IBOutlet weak var leafView: UIView! {
        didSet {
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
            var configuration = UIButton.Configuration.filled()
            configuration.cornerStyle = .capsule
            configuration.baseBackgroundColor = .darkBlue
            configuration.baseForegroundColor = .greenColor
            favoriteButton.configuration = configuration
        }
    }

    @IBAction func tappedFavorite(_ sender: Any) {
        favoriteButton.setNeedsUpdateConfiguration()
    }

}
