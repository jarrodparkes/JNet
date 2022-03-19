//
//  StarWarsPagingFetcher.swift
//  JNetExample
//
//  Created by Jarrod Parkes on 9/23/21.
//

import Foundation
import JNet

// MARK: - StarWarsPagingFetcher

class StarWarsPagingFetcher: PagingFetcher<StarWarsResult<StarWarsPerson>, StarWarsPerson> {

    // MARK: Initializer

    init() {
        super.init(api: StarWarsApi(), coreRequest: StarWarsRequest.people)
    }

    // MARK: Fetcher

    override func responseToRecords(response: StarWarsResult<StarWarsPerson>) -> [StarWarsPerson] {
        return response.results
    }

    override func nextRequestQueryItems(response: StarWarsResult<StarWarsPerson>,
                                        items: [String: String?]) -> [String: String?] {
        if let next = response.next,
           let nextUrl = URL(string: next),
           let nextComponents = URLComponents(url: nextUrl, resolvingAgainstBaseURL: false),
           let page = nextComponents.queryItems?.first(where: { $0.name == "page" }) {
            return ["page": page.value]
        } else {
            return [:]
        }
    }
}
