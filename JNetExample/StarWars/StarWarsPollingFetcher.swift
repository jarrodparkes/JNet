//
//  StarWarsPollingFetcher.swift
//  JNetExample
//
//  Created by Jarrod Parkes on 3/19/22.
//

import Foundation
import JNet

// MARK: - StarWarsPollingFetcher

class StarWarsPollingFetcher: PollingFetcher<StarWarsPerson> {

    // MARK: Initializer

    init() {
        super.init(api: StarWarsApi(), coreRequest: StarWarsRequest.peopleId(1), pollingInterval: 30)
    }
}
