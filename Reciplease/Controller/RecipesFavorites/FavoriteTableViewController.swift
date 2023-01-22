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

        // UserDefaults
    let userDefaults = UserDefaults.standard
    let favorites = "favorites"

        // favorites recipes path of firebase
    let databaseReference: DatabaseReference = Database.database().reference()

    private lazy var favoritesRecipesReferencePath: DatabaseReference? = {
        guard let userID = Auth.auth().currentUser?.uid else { return nil }
        print("✅ FAVORITES_VC/USER: \(String(describing: userID))")

        let favoritesRecipesReferencePath = databaseReference.child("users/\(userID)/favoritesRecipes")
        return favoritesRecipesReferencePath
    }()

    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    var isFavorite: Bool = false


        // -------------------------------------------------------
        //MARK: - outlets
        // -------------------------------------------------------

    @IBOutlet var favoritesRecipesTableView: UITableView!
    @IBOutlet weak var totalFavoritesRecipes: UILabel!

        // -------------------------------------------------------
        //MARK: - life cycle
        // -------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        showFavoritesRecipes()
    }

    @IBAction func tappedSignOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            print("✅ RECIPE_VC/BUTTON_SIGNOUT: User is sign out")
            dismiss(animated: true)
        } catch {
            print("🛑 RECIPE_VC/BUTTON_SIGNOUT: SignOut impossible")
        }
    }

    
        // -------------------------------------------------------
        // MARK: - Table view data source
        // -------------------------------------------------------

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfFavoritesRecipes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "RecipeCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! RecipesTableViewCell

            // initialize recipeID
        lazy var recipeID: String = {
            let uri = listOfFavoritesRecipes[indexPath.row].uri
            let recipeID = uri.split(separator: "#").last.map(String.init)
            print("✅ FAVORITES_VC/FIREBASE_SAVE: recipeID = \(recipeID as Any)")
            return recipeID ?? "not recipe ID"
        }()


        cell.titleLabel.text = listOfFavoritesRecipes[indexPath.row].title
        print("✅ FAVORITES_VC/TABLEVIEW: 🍜 \(String(describing: cell.titleLabel.text))")

        listOfFavoritesRecipes[indexPath.row].ingredients.forEach({ ingredient in
            cell.ingredientsLabel.text = ingredient.food
            print("✅ FAVORITES_VC/TABLEVIEW: 🍓 \(String(describing: cell.ingredientsLabel.text))")
        })

        let urlImage = URL(string: listOfFavoritesRecipes[indexPath.row].image)!
        if let dataImage = try? Data(contentsOf: urlImage) {
            self.uploadImage(image: dataImage, ID: recipeID)
            cell.recipeImage.image = UIImage(data: dataImage)
        }
        print("✅ FAVORITES_VC/TABLEVIEW: 🖼 \(String(describing: cell.recipeImage.image))")

            // check these recipes is favorites according to save in userDefaults
        let savedFavorites: [String] = userDefaults.array(forKey: favorites) as? [String] ?? []
        if savedFavorites.contains(recipeID) {
            isFavorite = true
            print("✅⭐️ FAVORITES_VC/CELL: Recipe is ever favorite")
        }

            // update image button according by the isFavorite
        cell.favoriteButton.configurationUpdateHandler = { button in
            var configuration = button.configuration
            let symbolName = self.isFavorite ? "star.fill" : "star"
            configuration?.image = UIImage(systemName: symbolName)
            cell.favoriteButton.configuration = configuration
        }

             // action of favorite button
        cell.favoriteButton.addAction(
            UIAction { _ in
                if self.isFavorite {
                    self.isFavorite = false
                    print("✅🙈 FAVORITES_VC/FAVORITE_BUTTON: Recipe is not favorite")
                    self.favoritesRecipesReferencePath?.child(recipeID).removeValue()
                    self.favoritesRecipesIDInUserDefaults(recipeID, isFavorites: false)
                } else {
                    self.isFavorite = true
                    let recipeForDetails = self.listOfFavoritesRecipes[indexPath.row]
                    print("✅⭐️ FAVORITES_VC/FAVORITE_BUTTON: Recipe is favorite")
                    self.savefavoriteRecipe(recipe: recipeForDetails, recipeID: recipeID)
                    self.favoritesRecipesIDInUserDefaults(recipeID, isFavorites: true)
                }
            },
            for: .touchUpInside)

        return cell
    }


    func favoritesRecipesIDInUserDefaults(_ recipeID: String, isFavorites: Bool) {
            // if not info create a empty array
        var savedFavorites: [String] = userDefaults.array(forKey: favorites) as? [String] ?? []

        if isFavorites && !savedFavorites.contains(where: {$0 == recipeID}) {
            savedFavorites.append(recipeID)
            print("✅ FAVORITES_VC/USERDEFAULTS: Recipe is save in favorites: \(savedFavorites)")
        } else {
            savedFavorites = savedFavorites.filter({ $0 != recipeID })
//            savedFavorites.removeAll(where: { $0 == recipeID })
            print("✅ FAVORITES_VC/USERDEFAULTS: Recipe is delete in favorites: \(savedFavorites)")
        }
            // setting userDefaults
        userDefaults.set(savedFavorites, forKey: favorites)
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

extension FavoriteTableViewController {

        //MARK: - recover the favorites recipes in firebase

    func uploadImage(image: Data, ID: String) {
        let userID = Auth.auth().currentUser?.uid
        let storageReference = Storage.storage().reference()
        let imageReference = storageReference.child("users/\(userID ?? "")/recipeImages").child(ID)

        
        }
    }

    func createID(for recipe: API.Edamam.Recipe) -> String {
        let uri = recipe.uri
        let recipeID = uri.split(separator: "#").last.map(String.init)
        print("✅ FAVORITES_VC/CREATEID: recipeID = \(recipeID as Any)")
        return recipeID ?? "🛑 FAVORITES_VC/CREATEID: The recipeID hasn't create"
    }

    func savefavoriteRecipe(recipe: API.Edamam.Recipe, recipeID: String) {
        let recipe = API.Edamam.Recipe(uri: recipe.uri,
                                       title: recipe.title,
                                       image: recipe.image,
                                       source: recipe.source,
                                       sourceUrl: recipe.sourceUrl,
                                       numberOfPieces: recipe.numberOfPieces,
                                       healthLabels: recipe.healthLabels,
                                       cautions: recipe.cautions,
                                       ingredients: recipe.ingredients,
                                       calories: recipe.calories,
                                       totalTime: recipe.totalTime,
                                       cuisineType: recipe.cuisineType,
                                       mealType: recipe.mealType,
                                       isFavorite: recipe.isFavorite)

        do {
            let data = try encoder.encode(recipe)
            let json = try JSONSerialization.jsonObject(with: data)
            DispatchQueue.main.async {
                self.favoritesRecipesReferencePath?.child(recipeID).setValue(json)
                print("✅ FAVORITES_VC/FIREBASE_SAVE: Favorite recipe saved successfully")
            }

        } catch {
            print("🛑 FAVORITES_VC/FIREBASE_SAVE: Failed to save favorite recipe, \(error)")
        }
    }


        // -------------------------------------------------------
        //MARK: - list of favorites recipes
        // -------------------------------------------------------

    func showFavoritesRecipes() {
        favoritesRecipesReferencePath?.observe(.childAdded, with: { snapshot in
            let jsonOfFavoritesRecipes = snapshot.value as? [String: Any]
            print("✅ FAVORITES_VC/JSON: \(String(describing: snapshot.value))")

            do {
                let recipeData = try JSONSerialization.data(withJSONObject: jsonOfFavoritesRecipes as Any)
                let recipe = try self.decoder.decode(API.Edamam.Recipe.self, from: recipeData)
                self.listOfFavoritesRecipes.append(recipe)
                self.favoritesRecipesTableView.reloadData()
                self.totalFavoritesRecipes.text = "You are \(self.listOfFavoritesRecipes.count) favorites recipes"
                print("✅ FAVORITES_VC/JSON: recipe -> \(recipe)")
            } catch {
                print("🛑 FAVORITES_VC/TABLEVIEW: an error occurred", error)
            }
        })
    }
}

