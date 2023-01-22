//
//  APIEdamamRecipesTests.swift
//  RecipleaseTests
//
//  Created by Greg-Mini on 16/01/2023.
//

import XCTest
@testable import Reciplease

final class APIEdamamRecipesTests: XCTestCase {

    var urlSession: URLSession!
    var expectation: XCTestExpectation!

    var APIEdamam: API.Edamam.Recipes!
    let apiURL = URL(string: "https://api.edamam.com/api/recipes/v2?type=public&q=%5B%22rice%22,%20%22tomato%22,%20%22apple%22%5D&app_id=\(APIKeys.IdValue.rawValue)&app_key=\(APIKeys.keyValue.rawValue)")

    let stuffs = ["rice", "tomato","apple"]

    override func setUpWithError() throws {

            // Transform URLProtocol from MockURLProtocol
        URLProtocol.registerClass(MockURLProtocol.self)

            // Setup a configuration to use our mock
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]

            // Create the URLSession configurated
        urlSession = URLSession(configuration: configuration)
    }

    override func tearDownWithError() throws {
            // Stop the modification of class URLProtocol
        URLProtocol.unregisterClass(MockURLProtocol.self)
    }

    func test_GivenTheGoodURLRequestOfEdamamAPI_ThenTheGenerationOftheURLIsOk() {
        let urlEndpoint = API.EndPoint.recipes(stuffs: ["rice", "tomato","apple"]).url
        XCTAssertEqual(urlEndpoint, apiURL)
    }

    func test_GivenTheGoodURLRequestNewPageRecipe_ThenTheGenerationOftheURLIsOk() {
        let nextPage = "https://api.edamam.com/api/recipes/v2?q=rice%2C%20tomato%2C%20apple%20%20&app_key=269fde3a9ed8c6c87bee2e07b8f7ebe6&_cont=CHcVQBtNNQphDmgVQ3tAEX4BYlxtAgEDRmFJC2QWZFdxAgYBUXlSA2ISNVZ6AlcCF20SVWNCNVIlDAZSFTFAAGVANQF7BVYVLnlSVSBMPkd5BgMbUSYRVTdgMgksRlpSAAcRXTVGcV84SU4%3D&type=public&app_id=256576d2"
        let urlEndpoint = API.EndPoint.recipesNext(nextPage: nextPage).url
        XCTAssertEqual(urlEndpoint, URL(string: nextPage))
    }

    func test_GivenTheGoodURLWithIngredients_WhenIAskAListOfRecipes_ThenTheAnswerIsAListWithTheCheckedIngredients() {
            // Given
        expectation = expectation(description: "Expectation")

            //When
        let data = MockResponseData.edamamRecipesCorrectData

        MockURLProtocol.requestHandler = { request in
            let response = MockResponseData.responseOK
            return (response, data)
        }
            //Then
        API.QueryService.shared.getData(endpoint: .recipes(stuffs: stuffs),
                                        type: API.Edamam.Recipes.self) { result in
            switch result {
                case .failure(let error):
                    XCTFail(error.localizedDescription)

                case .success(let result):
                    let recipes = result
                    XCTAssertNotNil(true)
                    XCTAssertEqual(recipes.total, 339)
                    XCTAssertEqual(recipes.founded[0].recipe.uri, "http://www.edamam.com/ontologies/edamam.owl#recipe_7bdac9b3c8228df69d026c07389336e9")
                    XCTAssertEqual(recipes.founded[0].recipe.title, "Dinner Tonight: Tomato, Rice, and Andouille Soup Recipe")
                    XCTAssertEqual(recipes.founded[0].recipe.image, "https://edamam-product-images.s3.amazonaws.com/web-img/df0/df0c538b2479be7abaca4ef24076d6ef.jpg?X-Amz-Security-Token=IQoJb3JpZ2luX2VjENb%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaCXVzLWVhc3QtMSJHMEUCIQD%2BQwE99GAQA2c7TTyN42soli48nOYBjCMsGsKwZZSAKAIgfb6F5NenmEHtw6TF4OOVhkLs6Co2sG%2BY%2Bma6ES1O2%2BkqzAQIHhAAGgwxODcwMTcxNTA5ODYiDDw%2BNyii5A72MoCcZSqpBNycBVFKrXBmGWYWK%2FYISRZ%2BilJv3eA9OEMZjyyEBd%2BkCEr7n%2BXRN%2B49XQvfvpT2bklqKIrb4se4vZOjZfypzUMjIYmxvKW%2BmCqa%2FoaNb6%2FYxXoww1Zb02xsdnDjf1ToJ02O722oHNS9w7Mw1ggeqaGTS9An3Y2P6Eg%2BspgHQYM%2FmDk%2FRSBgIv%2BX0r8PWob%2FHXMG%2FbHObfX2DJpoBGA9D1iE37CnZsCIA7FGJ2GNMGElpyIeBJ2k2IkJ1427zb%2BCQoWwd%2Blwc7XgiwXQndgrleCoHGh0U7chq6TIoTD8%2FRI%2BJPxmnY9INLNaDMkSANw5PEJYkNcJXDR%2BGkzCWfxe4BjiDjCUunLEBO%2BCbfcCb26rwpZwB6RJup%2Be0GodeHvdMgPD7E3BxvHwEv%2FzH858tOQthhBReOuV6ML0dJEXhtcKEmr%2BMRRCC2kfdEg%2BN%2BRrz20QlfASaL2KeC7qtFdlxa181bUJPYapP5%2FthMMaa0PL0NU8BI4XZ0F9sJJS4wtR5B4qOmW9QOanA41UqDk4XFcgPLijpenSYMy4bs7iSjc6vuC6h1Vmq2a7sTFLxHHMCXPNrc%2BvF7WQ5gu2xLjvCIMid4HFZ9OyOdiKFUesEFViDjIdBM84PMmuGlaMgUy5YdN8ANid1iyg1gYkiBYsRyBfEHzGa4nCgQv2VxAKf%2FW9Qn8wO4hFD%2BRShlX8ckvlGRCc%2FBYmfIoOqsHVHaXdNFnG3210MWk6e4Ywk5qonQY6qQGU%2F%2B59OkVDjr5MPAXmACURfpfIwXZA%2FVTBQbBcNZVTHGBDo8%2FFLmSmQbMsSXpalwCogK2UB5GclSE8h%2BtsCOi%2FjRhPqLqAkX5bbEyBLzDErg4%2Fhgw0KGkgWKddOGH7ZLq3NC2cQ80PARTCTDoh7pTPq5wKoUVBPehWR6V7lnbLisK7i51ul%2FH5UZgdw2SeFdSoQJ0T0hFT%2FF9MEpeuatb5XFcxTGZz%2B9wc&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20221226T222728Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=ASIASXCYXIIFGKQ6YEL2%2F20221226%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Signature=32f2c4656ec58029b54b3dbf2bd39038e5495cf12869e1f58c180fdb1388fabd")
                    XCTAssertEqual(recipes.founded[0].recipe.source, "Serious Eats")
                    XCTAssertEqual(recipes.founded[0].recipe.numberOfPieces, 4.0)
                    XCTAssertEqual(recipes.founded[0].recipe.healthLabels, [
                        "Dairy-Free",
                        "Gluten-Free",
                        "Wheat-Free",
                        "Egg-Free",
                        "Peanut-Free",
                        "Tree-Nut-Free",
                        "Soy-Free",
                        "Fish-Free",
                        "Shellfish-Free",
                        "Pork-Free",
                        "Crustacean-Free",
                        "Mustard-Free",
                        "Sesame-Free",
                        "Lupine-Free",
                        "Mollusk-Free",
                        "Alcohol-Free",
                        "Sulfite-Free"
                    ])
                    XCTAssertEqual(recipes.founded[0].recipe.cautions, ["Sulfites"])
                    XCTAssertEqual(recipes.founded[0].recipe.ingredients[0].food, "andouille sausage")
                    XCTAssertEqual(recipes.founded[0].recipe.ingredients[0].weight, 141.747615625)
                    XCTAssertEqual(recipes.founded[0].recipe.ingredients[0].foodCategory, "Cured meats")
                    XCTAssertEqual(recipes.founded[0].recipe.ingredients[0].image, "https://www.edamam.com/food-img/b42/b423dbb86abcac27234d9a01fac11ea5.jpg")
                    XCTAssertEqual(recipes.founded[0].recipe.calories, 1386.9118235456563)
                    XCTAssertEqual(recipes.founded[0].recipe.totalTime, 45.0)
                    XCTAssertEqual(recipes.founded[0].recipe.cuisineType, ["american"])
                    XCTAssertEqual(recipes.founded[0].recipe.mealType, ["lunch/dinner"])
            }
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }


    func test_GivenIAskATranslation_WhenINotRecoverAStatusCode500_ThenMyResponseFailed() {

        baseQueryCurrency(data: MockResponseData.edamamRecipesCorrectData, response: MockResponseData.responseFailed)

        API.QueryService.shared.getData(endpoint: .recipes(stuffs: stuffs),
                                        type: API.Edamam.Recipes.self) { result in
            switch result {
                case .failure(let error):
                    XCTAssertEqual(error.localizedDescription, "📭 Generic error: there is not a response!")

                case .success(let result):
                    XCTAssertNil(result)
                    XCTFail("shouldn't execute this block")
            }
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func test_GivenIAskAConversion_WhenIRecoverABadData_ThenDecodeJsonDataFailed() {

        baseQueryCurrency(data: MockResponseData.mockDataFailed, response: MockResponseData.responseOK)

        API.QueryService.shared.getData(endpoint: .recipes(stuffs: stuffs),
                                        type: API.Edamam.Recipes.self) { result in
            XCTAssertNotNil(result)

            switch result {
                case .failure(let error):
                    XCTAssertEqual(error.localizedDescription, "📬 Interne error: not decode data!")

                case .success(let result):
                    XCTAssertNil(result)
                    XCTFail("shouldn't execute this block")
            }
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }


        // -------------------------------------------------------
        //MARK: - Methode
        // -------------------------------------------------------

    private func baseQueryCurrency(data: Data?, response: HTTPURLResponse) {
        expectation = expectation(description: "Expectation")

        let data = data

        MockURLProtocol.requestHandler = { request in
            let response = response
            return (response, data)
        }
    }
}
