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
// pokemonFetcher.fetch()

let starWarsFetcher = StarWarsFetcher()
starWarsFetcher.delegate = fetcherLogger
starWarsFetcher.fetch()

RunLoop.main.run()
