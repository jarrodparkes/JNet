//
//  StarWarsRequest.swift
//  JNetExample
//
//  Created by Jarrod Parkes on 9/23/21.
//

import Foundation
import JNet

// MARK: - StarWarsRequest

enum StarWarsRequest: Request {
    case people
    case peopleId(Int)

    var path: String {
        switch self {
        case .people: return "people"
        case .peopleId(let id): return "people/\(id)"
        }
    }

    var responseType: Decodable.Type {
        switch self {
        case .people, .peopleId: return StarWarsResult<StarWarsPerson>.self
        }
    }

    var httpMethod: HttpMethod {
        switch self {
        case .people, .peopleId: return .get
        }
    }

    var httpQueryItems: [URLQueryItem] {
        return []
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
