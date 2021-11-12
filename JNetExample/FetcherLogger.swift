//
//  FetcherLogger.swift
//  JNetExample
//
//  Created by Jarrod Parkes on 10/27/21.
//

import JNet

// MARK: - FetcherLogger: FetcherDelegate

class FetcherLogger: FetcherDelegate {
    func fetcherStarted(fetcherTag: Int, firstPage: Bool) {
        print("started:fetcherTag:\(fetcherTag):firstPage:\(firstPage)")
    }

    func fetcherFetchedNewRecords(fetcherTag: Int,
                                  records: [UUIDIdentifiable],
                                  firstPage: Bool,
                                  fetchedAllRecords: Bool) {
        print("newRecords:fetcherTag:\(fetcherTag):records:\(records):" +
                "firstPage:\(firstPage):fetchedAllRecords:\(fetchedAllRecords)")
    }

    func fetcherFailed(fetcherTag: Int, statusCode: Int, error: Error) {
        print("failed:fetcherTag:\(fetcherTag):statusCode:\(statusCode):error:\(error)")
    }
}
