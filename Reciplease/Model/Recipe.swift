//
//  Recipe.swift
//  Reciplease
//
//  Created by Greg-Mini on 23/12/2022.
//

import UIKit 

struct Recipe {
    let title: String
    let image: String
    let ingredients: [Ingredient]
    let durationInMinutes: Int
    let note: Int?
    let favorite: Bool = false
}
