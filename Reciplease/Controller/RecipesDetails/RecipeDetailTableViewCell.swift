//
//  RecipeDetailTableViewCell.swift
//  Reciplease
//
//  Created by Greg Deveaux on 04/01/2023.
//

import UIKit

class RecipeDetailTableViewCell: UITableViewCell {

        // -------------------------------------------------------
        //MARK: - properties
        // -------------------------------------------------------

    var ingredients: [API.Edamam.Ingredients] = []


        // -------------------------------------------------------
        //MARK: - outlets
        // -------------------------------------------------------

    @IBOutlet weak var ingredientsCollectionView: UICollectionView!

    override func awakeFromNib() {
        super.awakeFromNib()
        ingredientsCollectionView.delegate = self
        ingredientsCollectionView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}


    // -------------------------------------------------------
    //MARK: - cell ingredients collection
    // -------------------------------------------------------

extension RecipeDetailTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ingredients.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IngredientsCell", for: indexPath) as? IngredientsCollectionViewCell else {
            return UICollectionViewCell()
        }
        if let urlImage = URL(string: ingredients[indexPath.row].image ?? "image not found") {
            if let dataImage = try? Data(contentsOf: urlImage) {
                cell.ingredientImageView.image = UIImage(data: dataImage)
            }
        }
        print("✅ RECIPE_DETAIL_CELL/COLLECTION_VIEW: 🌠 \(String(describing: cell.ingredientImageView.image))")

        cell.ingredientNameLabel.text = "\(Int(ingredients[indexPath.row].weight)) g\n" + ingredients[indexPath.row].food
        return cell
    }
}
