//
//  ViewController.swift
//  Reciplease
//
//  Created by Greg-Mini on 23/12/2022.
//

import UIKit

class FridgeViewController: UIViewController {

    //MARK: properties
    var listOfStuffsFromFridge: [String] = ["orange", "lemon"]

    //MARK: outlet
    @IBOutlet weak var stuffsFromFridgeTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var searchRecipes: UIButton!
    @IBOutlet weak var listOfStuffsFromFridgeTableView: UITableView!

        //MARK: view did load
    override func viewDidLoad() {
        super.viewDidLoad()
    }

        //MARK: actions
    @IBAction func tappedAddStuffsFromFridge(_ sender: Any) {
        addStuffFromFridgeInTheList()
    }

    private func addStuffFromFridgeInTheList() {
            // Check if there a stuff of fridge writted
        guard let newStuff = stuffsFromFridgeTextField.text, !newStuff.isEmpty else {
                // if the textField is empty give the user alert
            return presentAlert(with: "Please enter the stuff \n before tapped Add button, \n thank you 😃")
        }

            // add a new stuff of fridge in the array of the list
        listOfStuffsFromFridge.append(newStuff)

            // adapt the tableView with the new stuff
        let row = listOfStuffsFromFridge.count - 1
        let indexPath = IndexPath(row: row, section: 0)

        listOfStuffsFromFridgeTableView.beginUpdates()
        listOfStuffsFromFridgeTableView.insertRows(at: [indexPath], with: .top)
        listOfStuffsFromFridgeTableView.endUpdates()

            // reveal the inside of the tableView in debug
        print("✅ FRIDGE_VC/ADD: stuff added: \(newStuff)")
        dump(listOfStuffsFromFridge)

            // reinit a add stuffsFromFridgeTextField empty for new stuff
        stuffsFromFridgeTextField.text = ""
        view.endEditing(true)
    }

    @IBAction func tappedClearAllStuffsFromFridge(_ sender: Any) {
            // delete the whole stuffs of the list
        listOfStuffsFromFridge.removeAll()
        print("✅ FRIDGE_VC/CLEAR: all stuffs deleted: \(listOfStuffsFromFridge)")
            // delete the whole stuffs of the tableView
        listOfStuffsFromFridgeTableView.reloadData()
    }

    @IBAction func tappedSearchRecipes(_ sender: Any) {
        // send stuff to recover the possible recipes
        API.QueryService.shared.getData(endpoint: .recipes(stuffs: listOfStuffsFromFridge), type: API.Edamam.Recipes.self) { result in

            var listOfRecipesFounded: [Recipe] = []

            switch result {
                case .success(let recipes):
                    let recipesFrom = recipes.from
                    let recipesTo = recipes.to
                    let recipesTotal = recipes.total
                    print("✅ FRIDGE_VC/SEARCH: \(recipesTotal) recipes founded")
                    dump(recipes)

                    for recipe in recipes.founded {
                        let title = recipe.recipe.title

                        let urlString = recipe.recipe.image
                        guard let imageURL = URL(string: urlString) else { return }
                        let image = imageURL

                        let totalTime = Int(recipe.recipe.totalTime)

                        let ingredients: [Ingredient] = {
                            let ingredientsReceive = recipe.recipe.ingredients
                            var ingredients: [Ingredient] = []
                            for ingredient in ingredientsReceive {
                                let newIngredient = Ingredient(foodCategory: ingredient.foodCategory, image: ingredient.image, weight: ingredient.weight, food: ingredient.food)
                                ingredients.append(newIngredient)
                            }
                            return ingredients
                        }()

                        let recipeFounded = Recipe(title: title, image: urlString, ingredients: ingredients, durationInMinutes: totalTime, note: nil)
                        listOfRecipesFounded.append(recipeFounded)
                    }

                    self.performSegue(withIdentifier: "SegueListOfRecipe", sender: listOfRecipesFounded)

                case .failure(let error):
                    self.presentAlert(with: "Sorry, there was a problem, please try again")
                    print("🛑 FRIDGE_VC/SEARCH: \(error.localizedDescription)")
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueListOfRecipe" {
            let destinationController = segue.destination as? RecipesTableViewController
            guard let recipe = sender as? Recipe else { return }
            destinationController?.listOfRecipes.append(recipe)
            print("✅ FRIDGE_VC/SEGUE: \(String(describing: destinationController?.listOfRecipes))")
            destinationController?.listOfRecipesTableView.reloadData()
        }
    }

}

    //MARK: - list of stuffs from fridge TableView
extension FridgeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfStuffsFromFridge.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "StuffsFromFridge"
        let cell = listOfStuffsFromFridgeTableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)

        cell.textLabel?.text = "• \(listOfStuffsFromFridge[indexPath.row])"

        return cell
    }
}

extension FridgeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
                // delete the stuff of the list
            listOfStuffsFromFridge.remove(at: indexPath.row)
                // delete the stuff line of the tableView
            listOfStuffsFromFridgeTableView.beginUpdates()
            listOfStuffsFromFridgeTableView.deleteRows(at: [indexPath], with: .fade)
            listOfStuffsFromFridgeTableView.endUpdates()
        }
    }
}

    // -------------------------------------------------------
    // MARK: Keyboard setup dismiss
    // -------------------------------------------------------

extension FridgeViewController: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        stuffsFromFridgeTextField.resignFirstResponder()
        return true
    }
}

