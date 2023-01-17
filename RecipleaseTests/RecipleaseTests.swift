//
//  RecipleaseTests.swift
//  RecipleaseTests
//
//  Created by Greg-Mini on 23/12/2022.
//

import XCTest
@testable import Reciplease

final class RecipleaseTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let uri = "https://uri.com"
        let title = "Apple pie"
        let image = "apple pie image"
        let ingredients = [API.Edamam.Ingredients(image: "flour image",
                                                  weight: 250.0,
                                                  food: "flour",
                                                  foodCategory: "flour"),
                           API.Edamam.Ingredients(image: "egg image",
                                                  weight: 50.0,
                                                  food: "egg",
                                                  foodCategory: "egg"),
                           API.Edamam.Ingredients(image: "apple image",
                                                  weight: 200.0,
                                                  food: "apple",
                                                  foodCategory: "fruit")
                           ]
        let source = "source name"
        let sourceUrl = "site source"
        let numberOfPieces = 5.0
        let durationInMinutes = 65.0
        let healthLabels = ["label 1", "label 2"]
        let cautions = ["gluten"]
        let calories = 95.5
        let cuisineType = ["cuisineType"]
        let mealType = ["mealType"]
        let isFavorite = true
        let recipe = API.Edamam.Recipe(uri: uri,
                                       title: title,
                                       image: image,
                                       source: source,
                                       sourceUrl: sourceUrl,
                                       numberOfPieces: numberOfPieces,
                                       healthLabels: healthLabels,
                                       cautions: cautions,
                                       ingredients: ingredients,
                                       calories: calories,
                                       totalTime: durationInMinutes,
                                       cuisineType: cuisineType,
                                       mealType: mealType,
                                       isFavorite: isFavorite)

        XCTAssertNotNil(recipe)
        XCTAssertEqual(uri, recipe.uri)
        XCTAssertEqual(title, recipe.title)
        XCTAssertEqual(image, recipe.image)
        XCTAssertEqual(source, recipe.source)
        XCTAssertEqual(sourceUrl, recipe.sourceUrl)
        XCTAssertEqual(numberOfPieces, recipe.numberOfPieces)
        XCTAssertEqual(healthLabels, recipe.healthLabels)
        XCTAssertEqual(cautions, recipe.cautions)
        XCTAssertEqual(ingredients[0].food, recipe.ingredients[0].food)
        XCTAssertEqual(ingredients[1].image, recipe.ingredients[1].image)
        XCTAssertEqual(ingredients[2].weight, recipe.ingredients[2].weight)
        XCTAssertEqual(ingredients[2].foodCategory, recipe.ingredients[2].foodCategory)
        XCTAssertEqual(calories, recipe.calories)
        XCTAssertEqual(durationInMinutes, recipe.totalTime)
        XCTAssertEqual(cuisineType, recipe.cuisineType)
        XCTAssertEqual(mealType, recipe.mealType)
        XCTAssertEqual(isFavorite, recipe.isFavorite)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
