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
    enum Edamam {
            // number found and recipes
        struct Recipes: Decodable {
            let from: Int
            let to: Int
            let total: Int
            let otherRecipes: ShowOtherRecipes
            let founded: [RecipesFounded]

            enum CodingKeys: String, CodingKey {
                case from
                case to
                case total = "count"
                case otherRecipes = "_links"
                case founded = "hits"
            }
        }

        struct RecipesFounded: Decodable {
            let recipe: DetailsRecipes
        }

        struct ShowOtherRecipes: Decodable {
            let before: Links?
            let next: Links

            enum CodingKeys: String, CodingKey {
                case before = "self"
                case next
            }

            struct Links: Decodable {
                let href: String
            }
        }


        struct DetailsRecipes: Decodable {
            let uri: String
            let title: String
            let image: String
            let source: String
            let sourceUrl: String
            let numberOfPieces: Double
            let healthLabels: [String]
            let cautions: [String]
            let ingredients: [Ingredients]
            let calories: Double
            let totalTime: Double
            let cuisineType: [String]
            let mealType: [String]

            enum CodingKeys: String, CodingKey {
                case uri
                case title = "label"
                case image
                case source
                case sourceUrl = "url"
                case numberOfPieces = "yield"
                case healthLabels
                case cautions
                case ingredients
                case calories
                case totalTime
                case cuisineType
                case mealType
            }
        }

        struct Ingredients: Decodable {
            let image: String
            let weight: Double
            let food: String
            let foodCategory: String
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
        case recipes(stuffs: [String])

        var url: URL {
            var components = URLComponents()
            components.scheme = "https"

            switch self {
                case .recipes(let stuffs):
                    components.host = "api.edamam.com"
                    components.path = "/api/recipes/v2"
                    components.queryItems = [
                        URLQueryItem(name: "type", value: "public"),
                        URLQueryItem(name: "q", value: "\(stuffs)"),
                        URLQueryItem(name: "app_id", value: APIKeys.IdValue.rawValue),
                        URLQueryItem(name: "app_key", value: APIKeys.keyValue.rawValue)
                    ]
            }
            guard let url = components.url else {
                preconditionFailure("🛑 ENDPOINT: Invalid URL components: \(components) ")
            }

            return url
        }
    }
}
