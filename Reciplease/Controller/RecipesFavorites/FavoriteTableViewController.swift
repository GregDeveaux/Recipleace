//
//  FavoriteTableViewController.swift
//  Reciplease
//
//  Created by Greg Deveaux on 11/01/2023.
//

import UIKit
import Firebase
import FirebaseStorage

class FavoriteTableViewController: UITableViewController {

        //MARK: - properties
        // list for the favoriteRecipesTableView
    var listOfFavoritesRecipes: [API.Edamam.Recipe] = []

        // Loading indicator
    var isLoadingRecipes = true
    let activityIndicator = UIActivityIndicatorView(style: .large)

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
    lazy var favoritesRecipesReferencePath: DatabaseReference? = {
        guard let userID = Auth.auth().currentUser?.uid else { return nil }
        print("✅ FAVORITES_VC/USER: \(String(describing: userID))")

        let favoritesRecipesReferencePath = databaseReference.child("users/\(userID)/favoritesRecipes")
        return favoritesRecipesReferencePath
    }()


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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        favoritesRecipesTableView.reloadData()
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
        var isFavorite = self.savedFavorites.contains(recipeID)

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
        uploadImage(ID: recipeID, for: cell.recipeImage, indexPath: indexPath)
        print("✅ FAVORITES_VC/TABLEVIEW: 🖼 \(String(describing: cell.recipeImage.image))")

            // • 4d. update image button according by the isFavorite •
        var configuration = UIButton.Configuration.filled()
        configuration.cornerStyle = .capsule
        configuration.baseBackgroundColor = .darkBlue
        configuration.baseForegroundColor = .greenColor
        configuration.image = UIImage(systemName: "star.fill")

        cell.favoriteButton.configuration = configuration

            /// actions of favorite button
        cell.favoriteButton.addAction(
            UIAction { _ in
                if isFavorite {
                    print("✅🙈 FAVORITES_VC/FAVORITE_BUTTON: Recipe is not favorite")
                    self.favoritesRecipesReferencePath?.child(recipeID).removeValue()
                    self.favoritesRecipesIDInUserDefaults(recipeID, isFavorites: false)

                    self.listOfFavoritesRecipes.remove(at: indexPath.row)
                    
                    if self.favoritesRecipesTableView.numberOfRows(inSection: indexPath.section) == 0 {
                            /// remove TableView
                        self.favoritesRecipesTableView.deleteSections(NSIndexSet(index: indexPath.section) as IndexSet, with: .automatic)
                    }else{
                            /// remove Row
                        self.favoritesRecipesTableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                        /// change the sentence
                    if self.listOfFavoritesRecipes.count == 0 {
                        self.totalFavoritesRecipes.text = "Click on the star to add in the favorites"
                    } else {
                        self.totalFavoritesRecipes.text = "You are \(self.listOfFavoritesRecipes.count) favorites recipes"
                    }
                        /// add counter of all users app and update, here we just delete
                    favoritesCountReferencePath.setValue(["count": ServerValue.increment(-1)])
                    isFavorite = false
                }
            },
            for: .touchUpInside)

            // retrieve a global count of like for this recipe
        let getCounterFavoritesReferencePath = databaseReference.child("recipes/\(recipeID)/count")
        countFavoritesRecipes(dataPath: getCounterFavoritesReferencePath, countLabel: cell.numberOfLikeLabel)

        return cell
    }

        // present activity indicator if data is loading...
    func setupActivityIndicator() {
            /// wheel indicator
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .greenColor

        favoritesRecipesTableView.backgroundView = activityIndicator
    }

    func setupNavigationBar() {
            // Create a tranparency navigationBar
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
            // The image pass behind navigationBar and touch the top
        favoritesRecipesTableView.contentInsetAdjustmentBehavior = .never
    }


    func favoritesRecipesIDInUserDefaults(_ recipeID: String, isFavorites: Bool) {
            // if not info create a empty array

        if isFavorites && !savedFavorites.contains(where: {$0 == recipeID}) {
            savedFavorites.append(recipeID)
            print("✅ FAVORITES_VC/USERDEFAULTS: Recipe is save in favorites: \(savedFavorites)")
        } else {
            savedFavorites = savedFavorites.filter({ $0 != recipeID })
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
