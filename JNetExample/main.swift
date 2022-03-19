//
//  main.swift
//  JNetExample
//
//  Created by Jarrod Parkes on 9/23/21.
//

import Foundation

let fetcherLogger = FetcherLogger()

// let pokemonFetcher = PokemonFetcher()
// pokemonFetcher.delegate = fetcherLogger
// pokemonFetcher.tag = 1
// pokemonFetcher.fetch()

// let starWarsPagingFetcher = StarWarsPagingFetcher()
// starWarsPagingFetcher.delegate = fetcherLogger
// starWarsPagingFetcher.tag = 2
// starWarsPagingFetcher.fetch()

let starWarsPollingFetcher = StarWarsPollingFetcher()
starWarsPollingFetcher.delegate = fetcherLogger
starWarsPollingFetcher.tag = 3
starWarsPollingFetcher.fetch()

RunLoop.main.run()
