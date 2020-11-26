import Foundation

// MARK: - RequestFailure

public typealias RequestFailure = ((Int, Any?) -> Void)?

// MARK: - Request

public protocol Request {

    // MARK: Properties

    var path: String { get }
    var cachePath: String { get }
    var responseType: Decodable.Type { get }

    var httpMethod: HttpMethod { get }
    var httpQueryItems: [URLQueryItem] { get }
    var httpHeaders: [String: String] { get }
    func httpBody(dateEncodingStrategy: JSONEncoder.DateEncodingStrategy) -> Data?

    var retries: Int { get }
}

// MARK: - Request (Defaults)

public extension Request {
    var cachePath: String {
        var cachePath = path
        if !httpQueryItems.isEmpty {
            for httpQueryItem in httpQueryItems {
                if let value = httpQueryItem.value {
                    cachePath += "/\(httpQueryItem.name)/\(value)"
                }
            }
        }

        return "\(path).json"
    }

    func urlRequest(forAPI api: ApiDiscoverable) -> URLRequest? {
        var request: URLRequest?

        // build HTTP request...
        if let url = urlComponents(forAPI: api).url {
            var urlRequest = URLRequest(url: url)

            // method...
            urlRequest.httpMethod = httpMethod.rawValue

            // headers...
            for (key, value) in httpHeaders {
                urlRequest.addValue(value, forHTTPHeaderField: key)
            }

            // http body...
            if let httpBody = httpBody(dateEncodingStrategy: api.dateEncodingStrategy) {
                urlRequest.httpBody = httpBody
            }

            request = urlRequest
        }

        return request
    }

    func urlComponents(forAPI api: ApiDiscoverable) -> URLComponents {
        var components = URLComponents()
        components.scheme = api.scheme
        components.host = api.host

        if let subPath = api.subPath {
            components.path = "/\(subPath)/\(path)"
        } else {
            components.path = "/\(path)"
        }

        components.queryItems = httpQueryItems.isEmpty ? nil : httpQueryItems
        return components
    }
}
