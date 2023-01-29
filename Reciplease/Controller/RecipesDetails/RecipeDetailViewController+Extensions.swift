//
//  RecipeDetailViewController+Extensions.swift
//  Reciplease
//
//  Created by Greg Deveaux on 28/01/2023.
//

import UIKit
import SafariServices
import Firebase
import FirebaseStorage

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
        cell.ingredients = recipeForDetails.ingredients
        return cell
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {

        let activity: Bool = false

        guard section == 0 else { return nil }

        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 70))

        let recipeLinkButton: UIButton = .setupButton(style: UIButton.Configuration.filled(),
                                                      title: "Go to the recipe",
                                                      colorText: .darkBlue,
                                                      colorBackground: .greenColor,
                                                      image: "link",
                                                      accessibilityMessage: "link to the recipe",
                                                      activity: activity)
        recipeLinkButton.addAction(
            UIAction { _ in
                self.linkRecipe()
            },
            for: .touchUpInside)

        footerView.addSubview(recipeLinkButton)

        recipeLinkButton.frame = CGRect(x: 0, y: 0, width: 300, height: 50)
        recipeLinkButton.center = footerView.center

        return footerView
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }

    func linkRecipe() {
        guard let recipeURL = URL(string: recipeForDetails.sourceUrl) else { return }
        let safariViewController = SFSafariViewController(url: recipeURL)
        print("✅ RECIPE_DETAIL/SAFARI: url recipe: \(recipeURL)")
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
            print("✅ RECIPE_DETAIL_VC/FIREBASE_SAVE: recipeID = \(recipeID as Any)")
            return recipeID ?? "not recipe ID"
        }()

        imageReference.putData(image) { metadata, error in
            if let error = error {
                print("🛑 RECIPE_DETAIL_VC/FIREBASE_STORAGE: \(error.localizedDescription)")
                return
            }

            storageReference.downloadURL { downloadURL, error in
                guard let imageRecipeURL = downloadURL?.absoluteString else { return }
                UserDefaults.setValue(imageRecipeURL, forKey: recipeID)
                print("✅ RECIPE_DETAIL_VC/FIREBASE_STORAGE: 🖼 \(String(describing: imageRecipeURL))")
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
            let data = try JSONEncoder().encode(recipe)
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
                let recipe = try JSONDecoder().decode(API.Edamam.Recipe.self, from: recipeData)
                print(recipe)
            } catch {
                print("🛑 FAVORITES_VC/TABLEVIEW: an error occurred", error)
            }
        })
    }
}
