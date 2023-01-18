//
//  RecipesTableViewController.swift
//  Reciplease
//
//  Created by Greg-Mini on 26/12/2022.
//

import UIKit
import Firebase

class RecipesTableViewController: UITableViewController {

        // -------------------------------------------------------
        // MARK: - properties
        // -------------------------------------------------------

    var listOfStuffsFromFridge: [String] = []
    var listOfRecipes: [API.Edamam.RecipesFounded] = []

    var isLoadingRecipes = false
    let activityIndicator = UIActivityIndicatorView(style: .large)

    
        // -------------------------------------------------------
        //MARK: - outlets
        // -------------------------------------------------------

    @IBOutlet var listOfRecipesTableView: UITableView!
    @IBOutlet weak var totalRecipeLabel: UILabel!


        // -------------------------------------------------------
        //MARK: - cycle of views
        // -------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        setupActivityIndicator()
    }

    override func loadView() {
        super.loadView()

        receiveRecipes()
    }

    
        // -------------------------------------------------------
        // MARK: - receiveRecipes
        // -------------------------------------------------------

    func receiveRecipes() {
        print("✅ RECIPES_VC/RECEIVE: list of stuffs founded into the fridge sent to the API: \(listOfStuffsFromFridge)")
        self.isLoadingRecipes = true

        if isLoadingRecipes {
            activityIndicator.startAnimating()
            print("✅ RECIPES_VC/ACTIVITY_INDICATOR: start")
        }


        API.QueryService.shared.getData(endpoint: .recipes(stuffs: listOfStuffsFromFridge), type: API.Edamam.Recipes.self) { result in
            print("✅ RECIPES_VC/DATA: \(result)")

            switch result {
                case .success(let recipes):
                    let recipesTotal = recipes.total
                    self.totalRecipeLabel?.text = "Total reciepe founded: \(recipesTotal)"

                        // we save the data into the array of recipes
                    self.listOfRecipes = recipes.founded
                    print("✅ RECIPES_VC/RECEIVE: \(recipesTotal) recipes founded")
                    dump(self.listOfRecipes)

                    self.isLoadingRecipes = false
                    self.activityIndicator.stopAnimating()
                    self.listOfRecipesTableView.reloadData()

                case .failure(let error):
                    self.isLoadingRecipes = false
                    self.presentAlert(with: "Sorry, there was a problem, please try again")
                    print("🛑 RECIPES_VC/RECEIVE: \(error.localizedDescription)")
            }
        }
    }

        // present activity indicator if data is loading...
    func setupActivityIndicator() {
            // wheel indicator
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .greenColor

        listOfRecipesTableView.backgroundView = activityIndicator
    }


        // -------------------------------------------------------
        // MARK: - tableView
        // -------------------------------------------------------

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("✅ RECIPES_VC/TOTAL_ROWS: \(listOfRecipes.count)")
        return listOfRecipes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

//        let placeholder = UITableViewPlaceholder(insertionIndexPath: indexPath, reuseIdentifier: "MockRecipesTableViewCell", rowHeight: 150)
//        placeholder.cellUpdateHandler

        let cellIdentifier = "RecipeCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! RecipesTableViewCell
        cell.titleLabel.text = listOfRecipes[indexPath.row].recipe.title
        print("✅ RECIPES_VC/TABLEVIEW: 🍜 \(String(describing: cell.titleLabel.text))")

        listOfRecipes[indexPath.row].recipe.ingredients.forEach({ ingredient in
            cell.ingredientsLabel.text = ingredient.food
            print("✅ RECIPES_VC/TABLEVIEW: 🍓 \(String(describing: cell.ingredientsLabel.text))")
        })

        let urlImage = URL(string: listOfRecipes[indexPath.row].recipe.image)!
        if let dataImage = try? Data(contentsOf: urlImage) {
            cell.recipeImage.image = UIImage(data: dataImage)
        }
        print("✅ RECIPES_VC/TABLEVIEW: 🖼 \(String(describing: cell.recipeImage.image))")

        cell.favoriteButton.recipeIsSelected(listOfRecipes[indexPath.row].recipe)

        return cell
    }

    
        // -------------------------------------------------------
        // MARK: - Navigation
        // -------------------------------------------------------

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueDetailRecipe" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let destinationController = segue.destination as! RecipeDetailViewController
            destinationController.recipeForDetails = listOfRecipes[indexPath.row].recipe

            print("✅ RECIPES_VC/PREPARE: 🍜 \(String(describing: listOfRecipes[indexPath.row].recipe.title))")
            dump(listOfRecipes[indexPath.row].recipe)
        }
    }
}

