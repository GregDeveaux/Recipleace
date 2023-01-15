//
//  FavoriteTableViewController.swift
//  Reciplease
//
//  Created by Greg-Mini on 11/01/2023.
//

import UIKit
import Firebase
import FirebaseStorage

class FavoriteTableViewController: UITableViewController {

        //MARK: - properties
    var listOfFavoritesRecipes: [API.Edamam.Recipe] = []

    let databaseReference: DatabaseReference = Database.database().reference()

    private lazy var favoritesRecipesReferencePath: DatabaseReference? = {
        guard let userID = Auth.auth().currentUser?.uid else { return nil }
        print("✅ FAVORITES_VC/USER: \(String(describing: userID))")

        let favoritesRecipesReferencePath = databaseReference.child("users/\(userID)/favoritesRecipes")
        return favoritesRecipesReferencePath
    }()

    private let decoder = JSONDecoder()

        //MARK: - outlets
    @IBOutlet var favoritesRecipesTableView: UITableView!
    @IBOutlet weak var totalFavoritesRecipes: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showFavoritesRecipes()
    }


    func showFavoritesRecipes() {
        favoritesRecipesReferencePath?.observe(.childAdded, with: { snapshot in
            let jsonOfFavoritesRecipes = snapshot.value as? [String: Any]
            print("✅ FAVORITES_VC/JSON: \(String(describing: snapshot.value))")

            do {
                let recipeData = try JSONSerialization.data(withJSONObject: jsonOfFavoritesRecipes as Any)
                let recipe = try self.decoder.decode(API.Edamam.Recipe.self, from: recipeData)
                self.listOfFavoritesRecipes.append(recipe)
                self.favoritesRecipesTableView.reloadData()
            } catch {
                print("🛑 FAVORITES_VC/TABLEVIEW: an error occurred", error)
            }
        })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfFavoritesRecipes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "RecipeCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! RecipesTableViewCell

        cell.titleLabel.text = listOfFavoritesRecipes[indexPath.row].title
        print("✅ FAVORITES_VC/TABLEVIEW: 🍜 \(String(describing: cell.titleLabel.text))")

        listOfFavoritesRecipes[indexPath.row].ingredients.forEach({ ingredient in
            cell.ingredientsLabel.text = ingredient.food
            print("✅ FAVORITES_VC/TABLEVIEW: 🍓 \(String(describing: cell.ingredientsLabel.text))")
        })

        let urlImage = URL(string: listOfFavoritesRecipes[indexPath.row].image)!
        if let dataImage = try? Data(contentsOf: urlImage) {
            cell.recipeImage.image = UIImage(data: dataImage)
        }
        print("✅ FAVORITES_VC/TABLEVIEW: 🖼 \(String(describing: cell.recipeImage.image))")

        cell.favoriteButton?.recipeIsSelected(listOfFavoritesRecipes[indexPath.row])
        return cell
    }


    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueDetailFavoriteRecipe" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let destinationController = segue.destination as! RecipeDetailViewController
            destinationController.recipeForDetails = listOfFavoritesRecipes[indexPath.row]
            print("✅ FAVORITES_VC/PREPARE: 🍜 \(String(describing: listOfFavoritesRecipes[indexPath.row].title))")
            dump(listOfFavoritesRecipes[indexPath.row])
        }
    }

}
