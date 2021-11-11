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

let starWarsFetcher = StarWarsFetcher()
starWarsFetcher.delegate = fetcherLogger
starWarsFetcher.tag = 2
starWarsFetcher.fetch()

RunLoop.main.run()
