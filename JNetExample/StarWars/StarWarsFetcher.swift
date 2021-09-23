//
//  StarWarsFetcher.swift
//  JNetExample
//
//  Created by Jarrod Parkes on 9/23/21.
//

import Foundation
import JNet

// MARK: - StarWarsFetcher

class StarWarsFetcher: Fetcher<StarWarsResult<StarWarsPerson>, StarWarsPerson> {

    // MARK: Initializer

    init() {
        super.init(api: StarWarsAPI(), coreRequest: StarWarsRequest.people)
    }

    // MARK: Paginator

    override func responseToRecords(response: StarWarsResult<StarWarsPerson>) -> [StarWarsPerson] {
        return response.results
    }

    override func fetchStarted(firstPage: Bool) {
        print("fetchStarted")
    }

    override func fetchedNewRecords(records: [StarWarsPerson], firstPage: Bool) {
        print("fetchedNewRecords: \(records)")
    }

    override func fetchFailed(statusCode: Int, error: Error) {
        print("fetchFailed (\(statusCode)): \(error)")
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
