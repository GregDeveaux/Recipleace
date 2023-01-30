//
//  RecipeDetailViewController.swift
//  Reciplease
//
//  Created by Greg Deveaux on 23/12/2022.
//

import UIKit
import Firebase
import FirebaseStorage

class RecipeDetailViewController: UIViewController {

        // -------------------------------------------------------
        // MARK: - properties
        // -------------------------------------------------------

    var recipeForDetails: API.Edamam.Recipe!
    var favoritesRecipes: [API.Edamam.Recipe] = []

        // UserDefaults reference
    let userDefaults = UserDefaults.standard
    let favorites = "favorites"
    lazy var savedFavorites: [String] = {
        var savedFavorites = userDefaults.array(forKey: favorites) as? [String] ?? []
        return savedFavorites
    }()

        // Firebase reference
    private let databaseReference: DatabaseReference = Database.database().reference()
    lazy var favoritesRecipesReferencePath: DatabaseReference? = {
        guard let userID = Auth.auth().currentUser?.uid else { return nil }
        print("✅ RECIPES_DETAIL_VC/USER: \(String(describing: userID))")
            // path firebase
        let favoritesRecipesReferencePath = databaseReference.child("users/\(userID)/favoritesRecipes")
        return favoritesRecipesReferencePath
    }()

        // propertie to found ID of the recipe
    private lazy var recipeID: String = {
        let uri = self.recipeForDetails.uri
        let recipeID = uri.split(separator: "#").last.map(String.init)
        print("✅ RECIPE_DETAIL_VC/FIREBASE_SAVE: recipeID = \(recipeID as Any)")
        return recipeID ?? "not recipe ID"
    }()


        // -------------------------------------------------------
        // MARK: - outlets
        // -------------------------------------------------------

    @IBOutlet weak var recipeDetailTableView: UITableView!
    @IBOutlet weak var recipeImageView: UIImageView! {
        didSet {
                /// accessibility
            recipeImageView.isAccessibilityElement = true
            recipeImageView.accessibilityTraits = .image
            recipeImageView.accessibilityHint = "Image of the recipe"
        }
    }
    @IBOutlet weak var recipeTitleLabel: UILabel! {
        didSet {
            recipeTitleLabel.numberOfLines = 0
                /// accessibility
            recipeTitleLabel.isAccessibilityElement = true
            recipeTitleLabel.accessibilityTraits = .staticText
            recipeTitleLabel.accessibilityHint = "Title of the recipe"
        }
    }
    @IBOutlet weak var mealTypeLabel: UILabel! {
        didSet {
            mealTypeLabel.layer.cornerRadius = 10
            mealTypeLabel.layer.masksToBounds = true
                /// accessibility
            mealTypeLabel.isAccessibilityElement = true
            mealTypeLabel.accessibilityTraits = .staticText
            mealTypeLabel.accessibilityHint = "Category of the recipe"
        }
    }
    @IBOutlet weak var favoriteButton: UIButton! {
        didSet {
                // look if recipe is favorite in userDefaults
            var isFavorite = self.savedFavorites.contains(recipeID)
            
                // create a counter with likes of recipes
            let favoritesReferencePath = databaseReference.child("recipes")
            let favoritesCountReferencePath = favoritesReferencePath.child("\(self.recipeID)")

            var configuration = UIButton.Configuration.filled()
            configuration.baseForegroundColor = .greenColor
            configuration.baseBackgroundColor = .darkBlue
            configuration.cornerStyle = .capsule
            configuration.image = UIImage(systemName: "star")

                /// to activate modification design after  button  tapped
            favoriteButton.configurationUpdateHandler = { button in
                var configuration = button.configuration
                let symbolName = isFavorite ? "star.fill" : "star"
                configuration?.image = UIImage(systemName: symbolName)
                self.favoriteButton.configuration = configuration
            }
                /// accessibility
            favoriteButton.isAccessibilityElement = true
            favoriteButton.accessibilityTraits = .button
            favoriteButton.accessibilityHint = "add this recipe in your favorite recipes list"

                // create action of favorite button
            favoriteButton.addAction(
                UIAction { _ in
                if isFavorite {
                    print("✅ RECIPES_VC/TABLEVIEW: Recipe is not favorite")
                    self.favoritesRecipesReferencePath?.child(self.recipeID).removeValue()
                    self.favoritesRecipesIDInUserDefaults(self.recipeID, isFavorites: false)
                    /// add counter of all users app and update
                    favoritesCountReferencePath.setValue(["count": ServerValue.increment(-1)])
                    isFavorite = false

                } else {
                    print("✅ RECIPES_VC/TABLEVIEW: Recipe is favorite")
                    self.savefavoriteRecipe(recipe: self.recipeForDetails, recipeID: self.recipeID)
                    self.favoritesRecipesIDInUserDefaults(self.recipeID, isFavorites: true)
                        /// add counter of all users app and update
                    favoritesCountReferencePath.setValue(["count": ServerValue.increment(1)])
                    isFavorite = true
                }
            }, for: .touchUpInside)

                // update the configuration on the favorite button
            favoriteButton.configuration = configuration
        }
    }

    @IBOutlet weak var logOutButton: UIBarButtonItem! {
        didSet {
            logOutButton.customView?.layer.cornerRadius = 5
        }
    }

    @IBOutlet weak var countLabel: UILabel! {
        didSet {
                /// accessibility
            countLabel.isAccessibilityElement = true
            countLabel.accessibilityTraits = .staticText
            countLabel.accessibilityHint = "counter like of all users"
        }
    }

        // -------------------------------------------------------
        // MARK: - life cycle
        // -------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        recipeDetailTableView.delegate = self
        recipeDetailTableView.dataSource = self
        setupNavigationBar()
        setupRecipe()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        countFavoritesRecipes()
    }


        // -------------------------------------------------------
        //MARK: - setup design
        // -------------------------------------------------------

    func setupNavigationBar() {
            // Create a tranparency navigationBar
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
            // The image pass behind navigationBar and touch the top
        recipeDetailTableView.contentInsetAdjustmentBehavior = .never
    }

    func setupRecipe() {
        recipeTitleLabel.text = recipeForDetails.title
        mealTypeLabel.text = recipeForDetails.mealType[0].uppercased()
        print("✅ RECIPES_DETAIL_VC/RECEIVED: 🍜 \(String(describing: recipeForDetails.title))")
        dump(recipeForDetails)

        guard let urlImage = URL(string: recipeForDetails.image) else { return }
        if let dataImage = try? Data(contentsOf: urlImage) {
            recipeImageView.image = UIImage(data: dataImage)
            downloadImageFirebase(image: dataImage, ID: recipeID)
        }
    }


        // -------------------------------------------------------
        // MARK: - add favorite
        // -------------------------------------------------------

    @IBAction func tappedFavoriteButton(_ sender: Any) {
        favoriteButton.setNeedsUpdateConfiguration()
    }

    func favoritesRecipesIDInUserDefaults(_ recipeID: String, isFavorites: Bool) {
            // if not info create a empty array
        var savedFavorites: [String] = userDefaults.array(forKey: favorites) as? [String] ?? []

        if isFavorites && !savedFavorites.contains(where: {$0 == recipeID}) {
            savedFavorites.append(recipeID)
            print("✅ RECIPES_VC/USERDEFAULTS: Recipe is save in favorites: \(savedFavorites)")
        } else {
            savedFavorites.removeAll(where: { $0 == recipeID })
            print("✅ RECIPES_VC/USERDEFAULTS: Recipe is delete in favorites: \(savedFavorites)")
        }
            // setting userDefaults
        userDefaults.set(savedFavorites, forKey: favorites)
    }

    func countFavoritesRecipes() {
        let getCounterFavoritesReferencePath = databaseReference.child("recipes/\(recipeID)/count")

        getCounterFavoritesReferencePath.getData(completion: { error, snapshot in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            let counter = snapshot?.value as? Int ?? 0
            self.countLabel.text = "\(counter)"
            print("✅ 😍⭐️ RECIPES_VC/COUNT_FAVORITES_RECIPES: \(String(describing: self.countLabel.text))")
        })
    }
}
