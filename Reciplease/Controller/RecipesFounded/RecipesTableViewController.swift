//
//  RecipesTableViewController.swift
//  Reciplease
//
//  Created by Greg Deveaux on 26/12/2022.
//

import UIKit
import Firebase
import FirebaseStorage

class RecipesTableViewController: UITableViewController {

        // -------------------------------------------------------
        // MARK: - properties
        // -------------------------------------------------------

        // Recipes
    var listOfStuffsFromFridge: [String] = []
    var listOfRecipes: [API.Edamam.RecipesFounded] = []
    var nextPage: String = ""

        // Loading indicator
    var isLoadingRecipes = false
    let activityIndicator = UIActivityIndicatorView(style: .large)

        // UserDefaults to check favorites recipes present in firebase
    private let userDefaults = UserDefaults.standard
    private let favorites = "favorites"
    lazy var savedFavorites: [String] = {
        var savedFavorites = userDefaults.array(forKey: favorites) as? [String] ?? []
        return savedFavorites
    }()

        // Firebase reference
    let databaseReference: DatabaseReference = Database.database().reference()
    lazy var favoritesRecipesReferencePath: DatabaseReference? = {
        guard let userID = Auth.auth().currentUser?.uid else { return nil }
        print("✅ RECIPES_DETAIL_VC/USER: \(String(describing: userID))")
            /// path firebase
        let favoritesRecipesReferencePath = databaseReference.child("users/\(userID)/favoritesRecipes")
        return favoritesRecipesReferencePath
    }()

    
        // -------------------------------------------------------
        //MARK: - outlets
        // -------------------------------------------------------

    @IBOutlet var listOfRecipesTableView: UITableView!
    @IBOutlet weak var totalRecipeLabel: UILabel! {
        didSet {
            totalRecipeLabel.accessibilityTraits = .staticText
            totalRecipeLabel.accessibilityHint = "the total number of the possible recipes to load in the list"
        }
    }


        // -------------------------------------------------------
        //MARK: - lifecycle
        // -------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()

        setupActivityIndicator()
        receiveRecipes()
    }


        // -------------------------------------------------------
        // MARK: - receiveRecipes
        // -------------------------------------------------------

    func receiveRecipes() {
        print("✅ RECIPES_VC/RECEIVE: list of stuffs founded into the fridge sent to the API: \(listOfStuffsFromFridge)")
            // if the API is loading the recipe then activate activityIndicator
        self.isLoadingRecipes = true
        if isLoadingRecipes {
            activityIndicator.startAnimating()
            print("✅ RECIPES_VC/ACTIVITY_INDICATOR: start")
        }

            // recover data result of API
        API.QueryService.shared.getData(endpoint: .recipes(stuffs: listOfStuffsFromFridge), type: API.Edamam.Recipes.self) { [weak self] result in

            self?.dataRecipes(result: result)
            print("✅ RECIPES_VC/DATA: \(result)")

        }
    }

        // present activity indicator if data is loading...
    func setupActivityIndicator() {
            /// wheel indicator
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .greenColor

        listOfRecipesTableView.backgroundView = activityIndicator
    }

        // call the next page with url obtained of the last call
    func getNextRecipes(urlNextPage: String) {
        API.QueryService.shared.getData(endpoint: .recipesNext(nextPage: urlNextPage), type: API.Edamam.Recipes.self) { [weak self] result in
            self?.dataRecipes(result: result)
        }
    }

        // method to retrieve the recipes info
    private func dataRecipes(result: Result<API.Edamam.Recipes, API.Error>) {
        switch result {
            case .success(let recipes):
                let recipesTotal = recipes.total
                self.totalRecipeLabel?.text = "Total reciepe founded: \(recipesTotal)"

                    // we save the data into the array of recipes
                self.listOfRecipes.append(contentsOf: recipes.founded)
                print("✅ RECIPES_VC/RECEIVE: \(recipesTotal) recipes founded")
                dump(self.listOfRecipes)

                self.isLoadingRecipes = false
                self.activityIndicator.stopAnimating()
                self.listOfRecipesTableView.reloadData()
                guard let urlNextPage = recipes.otherRecipes?.next.href else { return }
                self.nextPage = urlNextPage

            case .failure(let error):
                self.isLoadingRecipes = false
                self.presentAlert(with: "Sorry, there was a problem, please try again")
                print("🛑 RECIPES_VC/RECEIVE: \(error.localizedDescription)")
        }
    }

        // -------------------------------------------------------
        // MARK: - tableView
        // -------------------------------------------------------
        // setup listOfRecipesTableView according to RecipeCell

        /// number of section(s)
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

        /// number of rows in section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("✅ RECIPES_VC/TOTAL_ROWS: \(listOfRecipes.count)")
        return listOfRecipes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            /// initialize cell
        let cellIdentifier = "RecipeCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! RecipesTableViewCell

            /// initialize recipeID
        lazy var recipeID: String = {
            let uri = listOfRecipes[indexPath.row].recipe.uri
            let recipeID = uri.split(separator: "#").last.map(String.init)
            print("✅ RECIPE_DETAIL_VC/FIREBASE_SAVE: recipeID = \(recipeID as Any)")
            return recipeID ?? "not recipe ID"
        }()
            /// title
        cell.titleLabel.numberOfLines = 0
        cell.titleLabel.text = listOfRecipes[indexPath.row].recipe.title
        print("✅ RECIPES_VC/TABLEVIEW: 🍜 \(String(describing: cell.titleLabel.text))")

            /// ingredients
        listOfRecipes[indexPath.row].recipe.ingredients.forEach({ ingredient in
            cell.ingredientsLabel.text = ingredient.food
            print("✅ RECIPES_VC/TABLEVIEW: 🍓 \(String(describing: cell.ingredientsLabel.text))")
        })
            /// image
        let urlImage = URL(string: listOfRecipes[indexPath.row].recipe.image)!
        if let dataImage = try? Data(contentsOf: urlImage) {
            cell.recipeImage.image = UIImage(data: dataImage)
        }
        print("✅ RECIPES_VC/TABLEVIEW: 🖼 \(String(describing: cell.recipeImage.image))")

            // retrieve a global count of like for this recipe
        let getCounterFavoritesReferencePath = databaseReference.child("recipes/\(recipeID)/count")
        countFavoritesRecipes(dataPath: getCounterFavoritesReferencePath, countLabel: cell.numberOfLikeLabel)
            /// button
        setupFavoriteButton(cell.favoriteButton, recipeID: recipeID, indexPath: indexPath)

        return cell
    }

    func favoritesRecipesIDInUserDefaults(_ recipeID: String, isFavorites: Bool) {
            // if not info create a empty array
        var savedFavorites: [String] = userDefaults.array(forKey: favorites) as? [String] ?? []

        if isFavorites && !savedFavorites.contains(where: {$0 == recipeID}) {
            savedFavorites.append(recipeID)
            print("✅ RECIPES_VC/USERDEFAULTS: Recipe is save in favorites: \(savedFavorites)")
        } else {
            savedFavorites = savedFavorites.filter({ $0 != recipeID })
            print("✅ RECIPES_VC/USERDEFAULTS: Recipe is delete in favorites: \(savedFavorites)")
        }
            // setting userDefaults
        userDefaults.set(savedFavorites, forKey: favorites)
    }

    func setupFavoriteButton(_ myFavoriteButton: UIButton, recipeID: String, indexPath: IndexPath) {
            // create a counter with likes of recipes
        let favoritesReferencePath = databaseReference.child("recipes")
        let favoritesCountReferencePath = favoritesReferencePath.child("\(recipeID)")

            // look if recipe is favorite in userDefaults
        var isFavorite = self.savedFavorites.contains(recipeID)

        var configuration = UIButton.Configuration.filled()
        configuration.cornerStyle = .capsule
        configuration.baseBackgroundColor = .darkBlue
        configuration.baseForegroundColor = .greenColor

            // update image button according by the isFavorite
        myFavoriteButton.configurationUpdateHandler = { button in
                // check these recipes is favorites according to save in userDefaults
            var configuration = button.configuration
            let symbolName = isFavorite ? "star.fill" : "star"
            configuration?.image = UIImage(systemName: symbolName)
            button.configuration = configuration
        }

             // action of favorite button
        myFavoriteButton.addAction(
            UIAction { _ in
                if isFavorite {
                    print("✅🙈 RECIPES_VC/FAVORITE_BUTTON: Recipe is not favorite")
                    self.favoritesRecipesReferencePath?.child(recipeID).removeValue()
                    self.favoritesRecipesIDInUserDefaults(recipeID, isFavorites: false)
                    configuration.image = UIImage(systemName: "star")
                    /// save in the counter firebase
                    favoritesCountReferencePath.setValue(["count": ServerValue.increment(-1)])
                    isFavorite = false

                } else {
                    let recipeForDetails = self.listOfRecipes[indexPath.row].recipe
                    print("✅⭐️ RECIPES_VC/FAVORITE_BUTTON: Recipe is favorite")
                    self.savefavoriteRecipe(recipe: recipeForDetails, recipeID: recipeID)
                    self.favoritesRecipesIDInUserDefaults(recipeID, isFavorites: true)
                    configuration.image = UIImage(systemName: "star.fill")
                        /// save in the counter firebase
                    favoritesCountReferencePath.setValue(["count": ServerValue.increment(1)])
                    isFavorite = true

                    let urlImage = URL(string: self.listOfRecipes[indexPath.row].recipe.image)!
                    if let dataImage = try? Data(contentsOf: urlImage) {
                        self.downloadImageFirebase(image: dataImage, ID: recipeID)
                    }
                }
            }, for: .touchUpInside)

        myFavoriteButton.configuration = configuration
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
