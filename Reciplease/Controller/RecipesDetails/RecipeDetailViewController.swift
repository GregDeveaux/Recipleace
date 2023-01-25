//
//  RecipeDetailViewController.swift
//  Reciplease
//
//  Created by Greg-Mini on 23/12/2022.
//

import UIKit
import Firebase
import FirebaseStorage
import SafariServices

class RecipeDetailViewController: UIViewController {

        //MARK: - properties
    var recipeForDetails: API.Edamam.Recipe!
    var favoritesRecipes: [API.Edamam.Recipe] = []
    var isFavorite: Bool = false

        // UserDefaults
    let userDefaults = UserDefaults.standard
    let favorites = "favorites"

        // Firebase reference
    let databaseReference: DatabaseReference = Database.database().reference()
    private lazy var favoritesRecipesReferencePath: DatabaseReference? = {
        guard let userID = Auth.auth().currentUser?.uid else { return nil }
        print("✅ RECIPES_DETAIL_VC/USER: \(String(describing: userID))")
            // path firebase
        let favoritesRecipesReferencePath = databaseReference.child("users/\(userID)/favoritesRecipes")
        return favoritesRecipesReferencePath
    }()

    private lazy var recipeID: String = {
        let uri = self.recipeForDetails.uri
        let recipeID = uri.split(separator: "#").last.map(String.init)
        print("✅ RECIPE_DETAIL_VC/FIREBASE_SAVE: recipeID = \(recipeID as Any)")
        return recipeID ?? "not recipe ID"
    }()

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()


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
    @IBOutlet weak var favoriteButton: UIButton! {
        didSet {
                // create a counter with likes of recipes
            let favoritesReferencePath = databaseReference.child("recipes")
            let favoritesCountReferencePath = favoritesReferencePath.child("\(self.recipeID)")

            var configuration = UIButton.Configuration.filled()
            configuration.baseForegroundColor = .greenColor
            configuration.baseBackgroundColor = .darkBlue
            configuration.cornerStyle = .capsule
            configuration.image = UIImage(systemName: "star")

            favoriteButton.configurationUpdateHandler = { button in
                var configuration = button.configuration
                let symbolName = self.isFavorite ? "star.fill" : "star"
                configuration?.image = UIImage(systemName: symbolName)
                self.favoriteButton.configuration = configuration
            }

                // update the configuration on the favorite button
            favoriteButton.configuration = configuration

                // create action of favorite button
            favoriteButton.addAction(
                UIAction { _ in
                if self.isFavorite {
                    self.isFavorite = false
                    print("✅ RECIPES_VC/TABLEVIEW: Recipe is not favorite")
                    self.favoritesRecipesReferencePath?.child(self.recipeID).removeValue()
                    self.favoritesRecipesIDInUserDefaults(self.recipeID, isFavorites: false)
                    /// add counter of all users app and update
                    favoritesCountReferencePath.setValue(["count": ServerValue.increment(-1)])
                } else {
                    self.isFavorite = true
                    print("✅ RECIPES_VC/TABLEVIEW: Recipe is favorite")
                    self.savefavoriteRecipe(recipe: self.recipeForDetails, recipeID: self.recipeID)
                    self.favoritesRecipesIDInUserDefaults(self.recipeID, isFavorites: true)
                    favoritesCountReferencePath.setValue(["count": ServerValue.increment(1)])
                }
            }, for: .touchUpInside)
        }
    }

    @IBOutlet weak var logOutButton: UIBarButtonItem! {
        didSet {
            logOutButton.customView?.layer.cornerRadius = 5
        }
    }

        //MARK: - view did load

    override func viewDidLoad() {
        super.viewDidLoad()
        recipeDetailTableView.delegate = self
        recipeDetailTableView.dataSource = self

        setupNavigationBar()
        setupRecipe()
    }

    func setupNavigationBar() {
            // Create a tranparency navigationBar
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
            // font navigationBar is greenColor
        navigationController?.navigationBar.tintColor = .greenColor
            // The image pass behind navigationBar and touch the top
        recipeDetailTableView.contentInsetAdjustmentBehavior = .never
    }

    func setupRecipe() {
        recipeTitleLabel.text = recipeForDetails.title
        mealTypeLabel.text = " " + recipeForDetails.mealType[0].uppercased() + " " 

        print("✅ RECIPES_DETAIL_VC/RECEIVED: 🍜 \(String(describing: recipeForDetails.title))")
        dump(recipeForDetails)

        guard let urlImage = URL(string: recipeForDetails.image) else { return }
        if let dataImage = try? Data(contentsOf: urlImage) {
            recipeImageView.image = UIImage(data: dataImage)
            downloadImageFirebase(image: dataImage, ID: recipeID)
        }
    }

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
}

extension RecipeDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "RecipeDetailTableViewCell"

        let cell = recipeDetailTableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! RecipeDetailTableViewCell
        cell.ingredientsLabel.text = "Ingredients"
        cell.ingredients = recipeForDetails.ingredients
        return cell
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {

        guard section == 0 else { return nil }

        var recipeLinkIsSentToSafari: Bool = false {
            didSet {
                recipeLinkButton.setNeedsUpdateConfiguration()
            }
        }

        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))

        let recipeLinkButton: UIButton = .setupButton(style: UIButton.Configuration.tinted(),
                                                      title: "Go to the recipe",
                                                      colorText: .white,
                                                      colorBackground: .greenColor,
                                                      image: "link",
                                                      accessibilityMessage: "link to the recipe",
                                                      activity: recipeLinkIsSentToSafari)
        recipeLinkButton.frame = CGRect(x: 0, y: 0, width: 300, height: 50)
        recipeLinkButton.center = footerView.center
        recipeLinkButton.addAction(
            UIAction { _ in
                self.linkRecipe()
            },
            for: .touchUpInside)

        footerView.addSubview(recipeLinkButton)
        return footerView
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }

    @objc func linkRecipe() {
        guard let recipeURL = URL(string: recipeForDetails.sourceUrl) else { return }
        let safariViewController = SFSafariViewController(url: recipeURL)
        present(safariViewController, animated: true)
    }
}

extension RecipeDetailViewController {

        //MARK: - save or remove the favorites recipes
    func downloadImageFirebase(image: Data, ID: String) {
        let userID = Auth.auth().currentUser?.uid
        let storageReference = Storage.storage().reference()
        let imageReference = storageReference.child("users/\(userID ?? "")/recipeImages").child(ID)

        lazy var recipeID: String = {
            let uri = self.recipeForDetails.uri
            let recipeID = uri.split(separator: "#").last.map(String.init)
            print("✅ FAVORITES_VC/FIREBASE_SAVE: recipeID = \(recipeID as Any)")
            return recipeID ?? "not recipe ID"
        }()

        imageReference.putData(image) { metadata, error in
            if let error = error {
                print("🛑 FAVORITES_VC/FIREBASE_STORAGE: \(error.localizedDescription)")
                return
            }

            storageReference.downloadURL { downloadURL, error in
                guard let imageRecipeURL = downloadURL?.absoluteString else { return }
                UserDefaults.setValue(imageRecipeURL, forKey: recipeID)
                print("✅ FAVORITES_VC/FIREBASE_STORAGE: 🖼 \(String(describing: imageRecipeURL))")
            }
        }
    }

    func createID(for recipe: API.Edamam.Recipe) -> String {
        let uri = recipe.uri
        let recipeID = uri.split(separator: "#").last.map(String.init)
        print("✅ RECIPE_DETAIL_VC/FIREBASE_SAVE: recipeID = \(recipeID as Any)")
        return recipeID ?? "🛑 The recipeID hasn't create"
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
                print("✅ RECIPE_DETAIL_VC/FIREBASE_SAVE: Favorite recipe saved successfully")
            }

        } catch {
            print("🛑 RECIPE_DETAIL_VC/FIREBASE_SAVE: Failed to save favorite recipe, \(error)")
        }
    }

    func showFavoritesRecipes() {
        favoritesRecipesReferencePath?.observe(.childAdded, with: { snapshot in
            let jsonOfFavoritesRecipes = snapshot.value as? [String: Any]
            print("✅ FAVORITES_VC/JSON: \(String(describing: snapshot.value))")

            do {
                let recipeData = try JSONSerialization.data(withJSONObject: jsonOfFavoritesRecipes as Any)
                let recipe = try self.decoder.decode(API.Edamam.Recipe.self, from: recipeData)
                print(recipe)
            } catch {
                print("🛑 FAVORITES_VC/TABLEVIEW: an error occurred", error)
            }
        })
    }
}
