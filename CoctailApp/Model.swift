//
//  Model.swift
//  CoctailApp
//
//  Created by Жеребцов Данил on 31.03.2022.
//

import Foundation

struct Drinks: Decodable {
    let drinks: [Coctail]
}

struct Coctail: Decodable {
    let strDrink: String
    let strDrinkThumb: String
    let idDrink: String
}
