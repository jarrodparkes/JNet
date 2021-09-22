import Foundation

// MARK: - ApiDiscoverable

public protocol ApiDiscoverable: AnyObject {
    var scheme: String { get }
    var host: String { get }
    var subPath: String? { get }

    var httpHeaderFields: [String: String] { get }
    var dateEncodingStrategy: JSONEncoder.DateEncodingStrategy { get }
}

// MARK: - APIJsonable: ApiDiscoverable

public protocol APIJsonable: ApiDiscoverable {
    func request<T: Codable>(_ request: URLRequest,
                             success: ((T) -> Void)?,
                             failure: RequestFailure) -> FetchOperation?

    func request<T: Codable>(_ request: Request,
                             success: ((T) -> Void)?,
                             failure: RequestFailure) -> FetchOperation?
}

// MARK: - APIJsonable (Defaults)

extension APIJsonable {
    func request<T: Codable>(_ request: Request,
                             success: ((T) -> Void)?,
                             failure: RequestFailure) -> FetchOperation? {
        if let urlRequest = request.urlRequest(forAPI: self) {
            return self.request(urlRequest, success: success, failure: failure)
        } else {
            return nil
        }
    }
}
