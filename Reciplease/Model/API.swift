//
//  API.swift
//  Reciplease
//
//  Created by Greg-Mini on 25/12/2022.
//

import Foundation

struct API {
        //MARK: - method
    enum Method: String {
        case GET, POST, PUSH
    }

        //MARK: - Edaman API Recipes
    enum RecipesEdamam {
            // number found and recipes
        struct Details: Decodable {
            var recipeFrom: Int
            var recipeTo: Int
            var totalRecipes: Int
            var otherRecipes: ShowOtherRecipes
            var recipesFounded: [RecipesFounded]

            enum CodingKeys: String, CodingKey {
                case recipeFrom = "from"
                case recipeTo = "to"
                case totalRecipes = "count"
                case otherRecipes = "_links"
                case recipesFounded = "hits"
            }
        }

        struct ShowOtherRecipes: Decodable {
            var before: Links
            var next: Links

            struct Links: Decodable {
                var href: String
            }
        }


        struct RecipesFounded: Decodable {
            var uri: String
            var title: String
            var image: String
            var source: String
            var sourceUrl: String
            var numberOfPieces: String
            var healthLabels: [String]
            var cautions: [String]
            var ingredients: [Ingredients]
            var calories: Double
            var totalTime: Double
            var cuisineType: String
            var mealType: String

            enum CodingKeys: String, CodingKey {
                case uri, image, source, totalTime
                case title = "label"
                case sourceUrl = "url"
                case numberOfPieces = "yield"
                case ingredients, cuisineType, mealType
                case healthLabels, cautions, calories
            }
            

        }

        struct Ingredients: Decodable {
            var image: String
            var weight: Double
            var food: String
            var foodCategory: String
        }
    }

    enum Error: LocalizedError {
        case generic(reason: String)
        case `internal`(reason: String)

        var errorDescription: String? {
            switch self {
            case .generic(let reason):
                return "🛑 Generic error: \(reason)"
            case .internal(let reason):
                return "🛑 Interne error: \(reason)"
            }
        }
    }

    enum EndPoint {
        var url: URL {
            var components = URLComponents()

            components.scheme = "https"
            components.host = "api.edamam.com"
            components.path = "/api/recipes/v2"
            components.queryItems = [
                URLQueryItem(name: "type", value: "public"),
                URLQueryItem(name: "q", value: ""),
                URLQueryItem(name: "app_id", value: APIKeys.IdValue.rawValue),
                URLQueryItem(name: "app_key", value: APIKeys.keyValue.rawValue)
            ]

            return components.url!
        }
    }
}
