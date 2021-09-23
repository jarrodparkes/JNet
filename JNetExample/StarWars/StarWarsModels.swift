//
//  StarWarsModels.swift
//  JNetExample
//
//  Created by Jarrod Parkes on 9/23/21.
//

import Foundation

// MARK: - StarWarsResult

struct StarWarsResult<T: Codable>: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [T]
}

// MARK: - StarWarsPerson

struct StarWarsPerson: Codable {
    let name, height, mass, hairColor: String
    let skinColor, eyeColor, birthYear: String
    let gender: StarWarsGender
    let homeworld: String
    let films, species, vehicles, starships: [String]
    let created, edited: String
    let url: String

    enum CodingKeys: String, CodingKey {
        case name, height, mass
        case hairColor = "hair_color"
        case skinColor = "skin_color"
        case eyeColor = "eye_color"
        case birthYear = "birth_year"
        case gender, homeworld, films, species, vehicles, starships, created, edited, url
    }
}

// MARK: - StarWarsGender

enum StarWarsGender: String, Codable {
    case female = "female"
    case male = "male"
    case nA = "n/a"
    case hermaphrodite = "hermaphrodite"
    case none = "none"
}
