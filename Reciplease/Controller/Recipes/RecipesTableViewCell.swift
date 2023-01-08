//
//  RecipesTableViewCell.swift
//  Reciplease
//
//  Created by Greg-Mini on 26/12/2022.
//

import UIKit

class RecipesTableViewCell: UITableViewCell {

    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ingredientsLabel: UILabel!
    @IBOutlet weak var numberOfLikeLabel: UILabel!
    @IBOutlet weak var favoriteImage: UIImageView!
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
}
