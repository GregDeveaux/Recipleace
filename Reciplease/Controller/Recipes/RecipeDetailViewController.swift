//
//  RecipeDetailViewController.swift
//  Reciplease
//
//  Created by Greg-Mini on 23/12/2022.
//

import UIKit
import Firebase
import SafariServices

class RecipeDetailViewController: UIViewController {

        //MARK: - properties

    var recipeForDetails: API.Edamam.Recipe!
    var favoritesRecipes: [API.Edamam.Recipe] = []
    let databaseReference: DatabaseReference = Database.database().reference()

    private lazy var favoritesRecipesReferencePath: DatabaseReference? = {
        guard let userID = Auth.auth().currentUser?.uid else { return nil }
        print("✅ RECIPES_DETAIL_VC/USER: \(String(describing: userID))")

        let favoritesRecipesReferencePath = databaseReference.child("users/\(userID)/favoritesRecipes")
        return favoritesRecipesReferencePath
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

            guard let favoritesRecipesReferencePath = favoritesRecipesReferencePath else { return }

            let recipe = API.Edamam.Recipe(uri: recipeForDetails.uri,
                                           title: recipeForDetails.title,
                                           image: recipeForDetails.image,
                                           source: recipeForDetails.source,
                                           sourceUrl: recipeForDetails.sourceUrl,
                                           numberOfPieces: recipeForDetails.numberOfPieces,
                                           healthLabels: recipeForDetails.healthLabels,
                                           cautions: recipeForDetails.cautions,
                                           ingredients: recipeForDetails.ingredients,
                                           calories: recipeForDetails.calories,
                                           totalTime: recipeForDetails.totalTime,
                                           cuisineType: recipeForDetails.cuisineType,
                                           mealType: recipeForDetails.mealType,
                                           isFavorite: true)

            do {
                let data = try encoder.encode(recipe)
                let json = try JSONSerialization.jsonObject(with: data)

                let recipeID: String = {
                    let uri = self.recipeForDetails.uri
                    let recipeID = uri.split(separator: "#").last.map(String.init)
                    print("✅ RECIPE_DETAIL_VC/FIREBASE_SAVE: recipeID = \(recipeID as Any)")
                    return recipeID ?? "not recipe ID"
                }()

                favoritesRecipesReferencePath.child(recipeID).setValue(json)
                print("✅ RECIPE_DETAIL_VC/FIREBASE_SAVE: Favorite recipe saved successfully")

            } catch {
                print("🛑 RECIPE_DETAIL_VC/FIREBASE_SAVE: Failed to save favorite recipe, \(error)")
            }
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

        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))

        let recipeLinkButton: UIButton = .setupButton(title: "Go to the recipe", color: .greenColor, image: "link", accessibilityMessage: "link to the recipe")
        recipeLinkButton.frame = CGRect(x: 0, y: 0, width: 300, height: 50)
        recipeLinkButton.center = footerView.center
        recipeLinkButton.addTarget(self, action: #selector(linkRecipe), for: .touchUpInside)

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
