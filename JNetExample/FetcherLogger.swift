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
        print("started:firstPage:\(firstPage)")
    }

    func fetcherFetchedNewRecords(records: [Codable], firstPage: Bool, fetchedAllRecords: Bool) {
        print("newRecords:records:\(records):firstPage:\(firstPage):fetchedAllRecords:\(fetchedAllRecords)")
    }

    func fetcherFailed(statusCode: Int, error: Error) {
        print("failed:statusCode:\(statusCode):error:\(error)")
    }
}
