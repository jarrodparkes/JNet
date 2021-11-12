//
//  PokemonModels.swift
//  JNetExample
//
//  Created by Jarrod Parkes on 9/23/21.
//

import Foundation
import JNet

// MARK: - PokemonResult

struct PokemonResult<T: Codable>: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [T]
}

// MARK: - Pokemon

struct Pokemon: UUIDCodable {
    let name: String
    let url: String

    var id: UUID { return UUID() }
}
