//
//  FavoriteButton.swift
//  Reciplease
//
//  Created by Greg-Mini on 15/01/2023.
//

import Foundation
import Firebase
import FirebaseStorage

class FavoriteButton: UIButton {

        //MARK: - protperties
        // Firebase reference
    let databaseReference: DatabaseReference = Database.database().reference()

    private lazy var favoritesRecipesReferencePath: DatabaseReference? = {
        guard let userID = Auth.auth().currentUser?.uid else { return nil }
        print("✅ FAVORITES_VC/USER: \(String(describing: userID))")
        let favoritesRecipesReferencePath = databaseReference.child("users/\(userID)/favoritesRecipes")
        return favoritesRecipesReferencePath
    }()

    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    var isFavorite = false


        //MARK: check favorite recipe
        // save recipe with ID create with URI
    func recipeIsSelected(_ recipe: API.Edamam.Recipe) {
        let recipeID = createID(for: recipe)
        let button = self

            // button configuration
        var configuration = UIButton.Configuration.filled()
        configuration.baseForegroundColor = .greenColor
            // image of button depending on activation
        button.configurationUpdateHandler = { [unowned self] button in
            var configuration = button.configuration
            let image = isFavorite ? "star.fill" : "star"
            configuration?.image = UIImage(systemName: image)
            button.configuration = configuration
        }

            // action to remove or add in the favorite list of recipes
        button.addAction(
            UIAction { _ in
                if self.isFavorite {
                    self.isFavorite = false
                    print("✅ RECIPES_VC/TABLEVIEW: Recipe is not favorite")
                    self.favoritesRecipesReferencePath?.child(recipeID).removeValue()
                } else {
                    self.isFavorite = true
                    print("✅ RECIPES_VC/TABLEVIEW: Recipe is favorite")
                    self.savefavoriteRecipe(recipe: recipe, recipeID: recipeID)
                }
            }, for: .touchUpInside)

        button.configuration = configuration
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

            favoritesRecipesReferencePath?.child(recipeID).setValue(json)
            print("✅ RECIPE_DETAIL_VC/FIREBASE_SAVE: Favorite recipe saved successfully")

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
            } catch {
                print("🛑 FAVORITES_VC/TABLEVIEW: an error occurred", error)
            }
        })
    }
}



