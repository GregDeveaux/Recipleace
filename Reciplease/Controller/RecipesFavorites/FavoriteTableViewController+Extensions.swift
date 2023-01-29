//
//  FavoriteTableViewController+Extensions.swift
//  Reciplease
//
//  Created by Greg Deveaux on 28/01/2023.
//

import UIKit
import Firebase
import FirebaseStorage

extension FavoriteTableViewController {
        // -------------------------------------------------------
        //MARK: - recover the favorites recipes in firebase
        // -------------------------------------------------------

        // upload the saved image that is in Firebase
    func uploadImage(ID: String, for imageView: UIImageView, indexPath: IndexPath) {
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

        imageReference.downloadURL { url, error in
            if let error = error {
                print("🛑 FAVORITES_VC/FIREBASE_STORAGE_URL: \(String(describing: error.localizedDescription))")
            } else {
                guard let url = url else { return }
                self.listOfFavoritesRecipes[indexPath.row].image = url.absoluteString
                print("✅ FAVORITES_VC/FIREBASE_STORAGE: 🖼 \(String(describing: self.listOfFavoritesRecipes[indexPath.row].image))")
            }
        }
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
                let recipe = try JSONDecoder().decode(API.Edamam.Recipe.self, from: recipeData)
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

