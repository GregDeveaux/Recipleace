//
//  MockResponseData.swift
//  RecipleaseTests
//
//  Created by Greg Deveaux on 16/01/2023.
//

import XCTest

    // simulation of the different calls of currency API
class MockResponseData {

        // -------------------------------------------------------
        //MARK: - Mock responses
        // -------------------------------------------------------

        // Create mock URL with statusCode Ok or failed
    static var apiURL = URL(string: "www.apple.fr")!

    static let responseOK = HTTPURLResponse(url: apiURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
    static let responseFailed = HTTPURLResponse(url: apiURL, statusCode: 500, httpVersion: nil, headerFields: nil)!


        // -------------------------------------------------------
        //MARK: - Mock datas
        // -------------------------------------------------------

        // recover bundle correct data for test
    static var edamamRecipesCorrectData: Data {
        let bundle = Bundle(for: MockResponseData.self)
        let urlExample = bundle.url(forResource: "RecipesRiceTomatoApple", withExtension: ".json")
        let data = try! Data(contentsOf: urlExample!)
        return data
    }

        // create failed response of the simulation
    static let mockDataFailed = "notGood".data(using: .utf8)

        // create fake image response of the simulation
    static let recipeImage = "fr.png".data(using: .utf8)!

}

