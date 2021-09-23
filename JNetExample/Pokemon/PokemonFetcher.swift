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
        super.init(api: PokemonAPI(), coreRequest: PokemonRequest.pokemon)
    }

    // MARK: Paginator

    override func responseToRecords(response: PokemonResult<Pokemon>) -> [Pokemon] {
        return response.results
    }

    override func fetchStarted(firstPage: Bool) {
        print("fetchStarted")
    }

    override func fetchedNewRecords(records: [Pokemon], firstPage: Bool) {
        print("fetchedNewRecords: \(records)")
    }

    override func fetchFailed(statusCode: Int, error: Error) {
        print("fetchFailed (\(statusCode)): \(error)")
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
