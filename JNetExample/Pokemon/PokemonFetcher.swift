//
//  PokemonFetcher.swift
//  JNetExample
//
//  Created by Jarrod Parkes on 9/23/21.
//

import Foundation
import JNet

// MARK: - PokemonFetcher

class PokemonFetcher: Fetcher<PokemonResult<Pokemon>, Pokemon> {

    // MARK: Initializer

    init() {
        super.init(api: PokemonApi(), coreRequest: PokemonRequest.pokemon)
    }

    // MARK: Fetcher

    override func responseToRecords(response: PokemonResult<Pokemon>) -> [Pokemon] {
        return response.results
    }

    override func nextRequestQueryItems(response: PokemonResult<Pokemon>,
                                        items: [String: String?]) -> [String: String?] {
        if let next = response.next,
           let nextUrl = URL(string: next),
           let nextComponents = URLComponents(url: nextUrl, resolvingAgainstBaseURL: false),
           let offset = nextComponents.queryItems?.first(where: { $0.name == "offset" }) {
            return ["offset": offset.value]
        } else {
            return [:]
        }
    }
}
