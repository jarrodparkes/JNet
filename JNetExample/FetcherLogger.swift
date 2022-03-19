//
//  FetcherLogger.swift
//  JNetExample
//
//  Created by Jarrod Parkes on 10/27/21.
//

import JNet

// MARK: - FetcherLogger: PagingFetcherDelegate

class FetcherLogger: PagingFetcherDelegate {
    func pagingFetcherStarted(tag: Int, firstPage: Bool) {
        print("started:tag:\(tag):firstPage:\(firstPage)")
    }

    func pagingFetcherFetchedNewRecords(tag: Int,
                                        records: [UUIDCodable],
                                        firstPage: Bool,
                                        fetchedAllRecords: Bool) {
        print("newRecords:tag:\(tag):records:\(records):" +
                "firstPage:\(firstPage):fetchedAllRecords:\(fetchedAllRecords)")
    }

    func pagingFetcherFailed(tag: Int, statusCode: Int, error: Error) {
        print("failed:tag:\(tag):statusCode:\(statusCode):error:\(error)")
    }
}

// MARK: - FetcherLogger: PollingFetcherDelegate

extension FetcherLogger: PollingFetcherDelegate {
    func pollingFetcherFailed(tag: Int, statusCode: Int, error: Error) {
        print("failed:tag:\(tag):statusCode:\(statusCode):error:\(error)")
    }

    func pollingFetcherFetchedResponse(tag: Int, record: Codable) {
        print("response:tag:\(tag):record:\(record)")
    }
}
