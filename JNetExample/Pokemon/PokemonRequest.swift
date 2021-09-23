//
//  PokemonRequest.swift
//  JNetExample
//
//  Created by Jarrod Parkes on 9/23/21.
//

import Foundation
import JNet

// MARK: - PokemonRequest

enum PokemonRequest: Request {
    case pokemon

    var path: String {
        switch self {
        case .pokemon: return "pokemon"
        }
    }

    var responseType: Decodable.Type {
        switch self {
        case .pokemon: return PokemonResult<Pokemon>.self
        }
    }

    var httpMethod: HttpMethod {
        switch self {
        case .pokemon: return .get
        }
    }

    var httpQueryItems: [URLQueryItem] {
        switch self {
        case .pokemon:
            return [
                URLQueryItem(name: "limit", value: "10")
            ]
        }
    }

    var httpHeaders: [String: String] {
        return [:]
    }

    func httpBody(dateEncodingStrategy: JSONEncoder.DateEncodingStrategy) -> Data? {
        return nil
    }

    var retries: Int {
        return 0
    }
}
