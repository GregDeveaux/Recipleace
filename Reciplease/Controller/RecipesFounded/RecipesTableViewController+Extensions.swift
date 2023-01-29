//
//  RecipesTableViewController+Extensions.swift
//  Reciplease
//
//  Created by Greg Deveaux on 28/01/2023.
//

import UIKit
import Firebase
import FirebaseStorage

extension RecipesTableViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        print("🔰 RECIPES_VC/DATA_PREFETCH: \(indexPaths)")

        indexPaths.forEach { indexpath in
            if indexpath.row == listOfRecipes.count - 1 {
                getNextRecipes(urlNextPage: nextPage)
            }
        }
    }

    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        print("💢 RECIPES_VC/DATA_PREFETCH: \(indexPaths)")
    }
}


extension RecipesTableViewController {

        //MARK: - save the favorites recipes in firebase
    func downloadImageFirebase(image: Data, ID: String) {
        let userID = Auth.auth().currentUser?.uid
        let storageReference = Storage.storage().reference()
        let imageReference = storageReference.child("users/\(userID ?? "")/recipeImages").child(ID)

        imageReference.putData(image) { metadata, error in
            if let error = error {
                print("🛑 FAVORITES_VC/FIREBASE_STORAGE: \(error.localizedDescription)")
                return
            }

            storageReference.downloadURL { downloadURL, error in
                guard let imageRecipeURL = downloadURL?.absoluteString else { return }
                UserDefaults.setValue(imageRecipeURL, forKey: ID)
                print("✅ FAVORITES_VC/FIREBASE_STORAGE: 🖼 \(String(describing: imageRecipeURL))")
            }
        }
    }

    func createID(for recipe: API.Edamam.Recipe) -> String {
        let uri = recipe.uri
        let recipeID = uri.split(separator: "#").last.map(String.init)
        print("✅ RECIPES_VC/CREATEID: recipeID = \(recipeID as Any)")
        return recipeID ?? "🛑 RECIPES_VC/CREATEID: The recipeID hasn't create"
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
                print("✅ RECIPES_VC/FIREBASE_SAVE: Favorite recipe saved successfully")
            }

        } catch {
            print("🛑 RECIPES_VC/FIREBASE_SAVE: Failed to save favorite recipe, \(error)")
        }
    }

    func countFavoritesRecipes(dataPath: DatabaseReference, countLabel: UILabel) {

        dataPath.getData(completion:  { error, snapshot in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            let counter = snapshot?.value as? Int ?? 0
            countLabel.text = "\(counter)"
            print("✅ 😍⭐️ RECIPES_VC/COUNT_FAVORITES_RECIPES: \(String(describing: countLabel.text))")
        })
    }
}
