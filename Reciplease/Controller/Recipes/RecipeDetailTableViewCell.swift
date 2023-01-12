//
//  RecipeDetailTableViewCell.swift
//  Reciplease
//
//  Created by Greg-Mini on 04/01/2023.
//

import UIKit

class RecipeDetailTableViewCell: UITableViewCell {

        //MARK: - properties
    var ingredients: [API.Edamam.Ingredients] = []

        //MARK: - outlets
    @IBOutlet weak var ingredientsCollectionView: UICollectionView!
    @IBOutlet weak var ingredientsLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        ingredientsCollectionView.delegate = self
        ingredientsCollectionView.dataSource = self

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension RecipeDetailTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ingredients.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IngredientsCell", for: indexPath) as? IngredientsCollectionViewCell else {
            return UICollectionViewCell()
        }
        let urlImage = URL(string: ingredients[indexPath.row].image ?? "image not found")!   // TODO: problem optional
        if let dataImage = try? Data(contentsOf: urlImage) {
            cell.ingredientImageView.image = UIImage(data: dataImage)
        }
        print("✅ RECIPE_DETAIL_TVC/COLLECTION_VIEW: 🌠 \(String(describing: cell.ingredientImageView.image))")

        cell.ingredientNameLabel.text = ingredients[indexPath.row].food
        return cell
    }


}
