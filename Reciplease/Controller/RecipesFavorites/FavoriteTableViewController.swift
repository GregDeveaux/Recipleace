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
        // list for the favoriteRecipesTableView
    private var listOfFavoritesRecipes: [API.Edamam.Recipe] = []

        // UserDefaults to check favorites recipes present in firebase
    private let userDefaults = UserDefaults.standard
    private let favorites = "favorites"
    lazy var savedFavorites: [String] = {
        var savedFavorites = userDefaults.array(forKey: favorites) as? [String] ?? []
        return savedFavorites
    }()
    private var imageURL: URL!

        // favorites recipes path of firebase
    private let databaseReference: DatabaseReference = Database.database().reference()
    private lazy var favoritesRecipesReferencePath: DatabaseReference? = {
        guard let userID = Auth.auth().currentUser?.uid else { return nil }
        print("✅ FAVORITES_VC/USER: \(String(describing: userID))")

        let favoritesRecipesReferencePath = databaseReference.child("users/\(userID)/favoritesRecipes")
        return favoritesRecipesReferencePath
    }()

    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

        // init isFavorite for favoriteButton
    private var isFavorite = false


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
        // retrieve favorite in Firebase
        showFavoritesRecipes()
    }

    @IBAction func tappedSignOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            print("✅ RECIPE_VC/BUTTON_SIGNOUT: User is sign out")
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

            //  • 1. found recipeID of the recipe •
        lazy var recipeID: String = {
            let uri = listOfFavoritesRecipes[indexPath.row].uri
            let recipeID = uri.split(separator: "#").last.map(String.init)
            print("✅ FAVORITES_VC/FIREBASE_SAVE: recipeID = \(recipeID as Any)")
            return recipeID ?? "not recipe ID"
        }()

            //  • 2. check these recipes is favorites according to save in userDefaults •
        if savedFavorites.contains(recipeID) {
            isFavorite = true
            print("✅⭐️ FAVORITES_VC/CELL: Recipe is ever favorite")
        }

            // • 3.  create a counter with likes of recipes •
        let favoritesReferencePath = databaseReference.child("recipes")
        let favoritesCountReferencePath = favoritesReferencePath.child("\(recipeID)")

            //  • 4a. write title •
        cell.layoutIfNeeded()
        cell.titleLabel.text = listOfFavoritesRecipes[indexPath.row].title
        print("✅ FAVORITES_VC/TABLEVIEW: 🍜 \(String(describing: cell.titleLabel.text))")

            //  • 4b. write ingredients •
        listOfFavoritesRecipes[indexPath.row].ingredients.forEach({ ingredient in
            cell.ingredientsLabel.text = ingredient.food
            print("✅ FAVORITES_VC/TABLEVIEW: 🍓 \(String(describing: cell.ingredientsLabel.text))")
        })

            // • 4c. show image •
        uploadImage(ID: recipeID, for: cell.recipeImage)
        print("✅ FAVORITES_VC/TABLEVIEW: 🖼 \(String(describing: cell.recipeImage.image))")

            // • 4d. update image button according by the isFavorite •
        var configuration = UIButton.Configuration.filled()
        configuration.cornerStyle = .capsule
        configuration.baseBackgroundColor = .darkBlue
        configuration.baseForegroundColor = .greenColor

        cell.favoriteButton.configurationUpdateHandler = { button in
            var configuration = button.configuration
            let symbolName = self.isFavorite ? "star.fill" : "star"
            configuration?.image = UIImage(systemName: symbolName)
            cell.favoriteButton.configuration = configuration
        }

        /* MARK: action of favorite button */
        cell.favoriteButton.addAction(
            UIAction { _ in
                if self.isFavorite {
                    self.isFavorite = false
                    print("✅🙈 FAVORITES_VC/FAVORITE_BUTTON: Recipe is not favorite")
                    self.favoritesRecipesReferencePath?.child(recipeID).removeValue()
                    self.favoritesRecipesIDInUserDefaults(recipeID, isFavorites: false)
                    self.listOfFavoritesRecipes.remove(at: indexPath.row)
                    self.favoritesRecipesTableView.reloadData()
                    self.totalFavoritesRecipes.text = "You are \(self.listOfFavoritesRecipes.count) favorites recipes"
                    favoritesCountReferencePath.setValue(["count": ServerValue.increment(-1)])
                }
            },
            for: .touchUpInside)

        cell.favoriteButton.configuration = configuration
        return cell
    }


    func favoritesRecipesIDInUserDefaults(_ recipeID: String, isFavorites: Bool) {
            // if not info create a empty array

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

        // -------------------------------------------------------
        // MARK: - Navigation
        // -------------------------------------------------------
        // Send RecipeDetailViewController
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
        // -------------------------------------------------------
        //MARK: - recover the favorites recipes in firebase
        // -------------------------------------------------------

        // upload the saved image that is in Firebase
    func uploadImage(ID: String, for imageView: UIImageView) {
        let userID = Auth.auth().currentUser?.uid
        let storageReference = Storage.storage().reference()
        let imageReference = storageReference.child("users/\(userID ?? "")/recipeImages").child(ID)

            // retrieve image
        imageReference.getData(maxSize: 1 * 1024 * 1024, completion: { data, error in
            guard let data = data, error == nil else {
                print("🛑 FAVORITES_VC/FIREBASE_STORAGE: \(String(describing: error?.localizedDescription))")
                return
            }
            DispatchQueue.main.async {
                imageView.image = UIImage(data: data)
                print("✅ FAVORITES_VC/FIREBASE_STORAGE: 🖼 \(String(describing: imageView.image))")
            }
        })
    }


        // -------------------------------------------------------
        // MARK: - list of favorites recipes
        //         in Firebase
        // -------------------------------------------------------

    func showFavoritesRecipes() {
            // check recipes and retrieve
        favoritesRecipesReferencePath?.observe(.childAdded, with: { snapshot in
            let jsonOfFavoritesRecipes = snapshot.value as? [String: Any]

            do {
                let recipeData = try JSONSerialization.data(withJSONObject: jsonOfFavoritesRecipes as Any)
                let recipe = try self.decoder.decode(API.Edamam.Recipe.self, from: recipeData)
                    // save recipe in list of favorites
                self.listOfFavoritesRecipes.append(recipe)
                self.totalFavoritesRecipes.text = "You are \(self.listOfFavoritesRecipes.count) favorites recipes"
                print("✅ FAVORITES_VC/JSON: recipe is displayed")
            } catch {
                print("🛑 FAVORITES_VC/TABLEVIEW: an error occurred", error)
            }
                // reload the tableView
            self.favoritesRecipesTableView.reloadData()
        })
    }
}

