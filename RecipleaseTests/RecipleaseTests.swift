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
        let title = "Apple pie"
        guard let image = UIImage(named: "apple pie") else { return }
        let ingredients = ["flour", "egg", "apple"]
        let durationInMinutes = 65
        let note = 5
        let favorite = true
        let recipe = Recipe(title: title, image: image, ingredients: ingredients, durationInMinutes: durationInMinutes, note: note)

        XCTAssertNotNil(recipe)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
