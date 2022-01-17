//
//  StarWarsApi.swift
//  JNetExample
//
//  Created by Jarrod Parkes on 9/23/21.
//

import Foundation
import JNet

// MARK: - StarWarsApi

class StarWarsApi: ApiJsonable {
    let session = URLSession(configuration: .ephemeral)
    let queue = OperationQueue()

    func request<T: Codable>(_ request: URLRequest,
                             success: ((T) -> Void)?,
                             failure: RequestFailure) -> FetchOperation? {
        let fetch = FetchOperation(request: request, session: session)

        let parse = ParseOperation(type: T.self)
        parse.addDependency(fetch)
        parse.completionBlock = {
            DispatchQueue.main.async {
                guard !parse.isCancelled, !fetch.isCancelled else { return }

                if let httpResponse = parse.httpResponse, let decodedObject = true as? T,
                   httpResponse.hasSuccessfulStatusCode, T.self == Bool.self {
                    success?(decodedObject)
                } else if let decodedObject = parse.result as? T {
                    success?(decodedObject)
                } else if let statusCode = parse.httpResponse?.statusCode {
                    failure?(statusCode, parse.computedError)
                }
            }
        }

        DispatchQueue.main.async {
            if !fetch.isFinished { self.queue.addOperation(fetch) }
            if !parse.isFinished { self.queue.addOperation(parse) }
        }

        return fetch
    }

    var scheme: String { return "https" }
    var host: String { return "swapi.dev" }
    var subPath: String? { return "api" }
    var httpHeaderFields: [String: String] { return [:] }
    var dateEncodingStrategy: JSONEncoder.DateEncodingStrategy { return .deferredToDate }
}
