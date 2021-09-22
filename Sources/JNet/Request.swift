import Foundation

// MARK: - RequestFailure

/// A failure request handler which takes an `Int` (status code) and `Error` as input.
public typealias RequestFailure = ((Int, Error) -> Void)?

// MARK: - Request

/// Defines the URL components of a HTTP request such that a concrete `URLRequest` can be easily created.
public protocol Request {

    // MARK: Properties

    /// A URL path identifying a resource or file.
    var path: String { get }
    /// A file path for storing the results of this request.
    var cachePath: String { get }
    /// The type of object used when decoding raw data response.
    var responseType: Decodable.Type { get }

    /// The HTTP method to use for this request.
    var httpMethod: HttpMethod { get }
    /// URL parameters, also called query parameters or items, to include with the request.
    var httpQueryItems: [URLQueryItem] { get }
    /// HTTP headers to include with the request.
    var httpHeaders: [String: String] { get }

    /// Create `Data` to be included in the body of the request.
    /// - Parameter dateEncodingStrategy: Strategy used for encoding `Date` objects.
    func httpBody(dateEncodingStrategy: JSONEncoder.DateEncodingStrategy) -> Data?

    /// How many times should this request be tried before failing?
    var retries: Int { get }
}

// MARK: - Request (Defaults)

public extension Request {
    /// A file path for storing the results of this request.
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

    /// Creates a `URLRequest` from a `Request`'s URL components while also injecting API-specific URL
    /// components like scheme, host, and headers.
    /// - Parameter api: An API with its own specific URL components.
    /// - Returns: A `URLRequest`, if possible.
    func urlRequest(forAPI api: ApiDiscoverable) -> URLRequest? {
        var request: URLRequest?

        // build request...
        if let url = urlComponents(forAPI: api).url {
            var urlRequest = URLRequest(url: url)

            // method...
            urlRequest.httpMethod = httpMethod.rawValue

            // headers...
            let allHeaders = httpHeaders.merging(api.httpHeaderFields) { (_, apiHeaders) in apiHeaders }
            for (key, value) in allHeaders {
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

    private func urlComponents(forAPI api: ApiDiscoverable) -> URLComponents {
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
