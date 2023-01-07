//
//  RecipeDetailViewController.swift
//  Reciplease
//
//  Created by Greg-Mini on 23/12/2022.
//

import UIKit

class RecipeDetailViewController: UIViewController {

        //MARK: - properties

    var recipeForDetails: API.Edamam.Recipe!

        //MARK: - outlets

    @IBOutlet weak var recipeDetailTableView: UITableView!
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var recipeTitleLabel: UILabel! {
        didSet {
            recipeTitleLabel.numberOfLines = 0
        }
    }
    @IBOutlet weak var mealTypeLabel: UILabel! {
        didSet {
            mealTypeLabel.layer.cornerRadius = 10
            mealTypeLabel.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var favoriteButton: UIBarButtonItem!


        //MARK: - view did load

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        recipeDetailTableView.delegate = self
        recipeDetailTableView.dataSource = self

        setupRecipe()
    }

    func setupNavigationBar() {
            // Create a tranparency navigationBar
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
            // font navigationBar is white
        navigationController?.navigationBar.tintColor = .white
            // The image pass behind navigationBar and touch the top
        recipeDetailTableView.contentInsetAdjustmentBehavior = .never
    }

    func setupRecipe() {
        recipeTitleLabel.text = recipeForDetails.title
        mealTypeLabel.text = recipeForDetails.mealType[0]

        print("✅ RECIPES_DETAIL_VC/RECEIVED: 🍜 \(String(describing: recipeForDetails.title))")
        dump(recipeForDetails)

        guard let urlImage = URL(string: recipeForDetails.image) else { return }
        if let dataImage = try? Data(contentsOf: urlImage) {
            recipeImageView.image = UIImage(data: dataImage)
        }
    }
    @IBAction func TappedFavorite(_ sender: Any) {
        if !recipeForDetails.isFavorite {
            favoriteButton.image = UIImage(systemName: "heart.fill")
            favoriteButton.tintColor = .red
            recipeForDetails.isFavorite = true
        }
        else {
            favoriteButton.image = UIImage(systemName: "heart")
            recipeForDetails.isFavorite = false
        }
    }

}

extension RecipeDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "RecipeDetailTableViewCell"

        switch indexPath.row {
            case 0:
                let cell = recipeDetailTableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! RecipeDetailTableViewCell
                cell.ingredientsLabel.text = "Ingredients"
                cell.ingredients = recipeForDetails.ingredients
                return cell
            default:
                let cell = recipeDetailTableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! RecipeDetailTableViewCell
                cell.ingredientsLabel.text = "Recipe"
                return cell
        }
    }
}
