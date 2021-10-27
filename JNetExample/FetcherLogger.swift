//
//  FetcherLogger.swift
//  JNetExample
//
//  Created by Jarrod Parkes on 10/27/21.
//

import JNet

// MARK: - FetcherLogger: FetcherDelegate

class FetcherLogger: FetcherDelegate {
    func fetcherStarted(firstPage: Bool) {
        print("fetcherStarted:firstPage:\(firstPage)")
    }

    func fetcherFetchedNewRecords(records: [Codable], firstPage: Bool) {
        print("fetcherFetchedNewRecords:records:\(records):firstPage:\(firstPage)")
    }

    func fetcherFailed(statusCode: Int, error: Error) {
        print("fetcherFailed:statusCode:\(statusCode):error:\(error)")
    }
}
