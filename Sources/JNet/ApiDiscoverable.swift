import Foundation

// MARK: - ApiDiscoverable

public protocol ApiDiscoverable: AnyObject {
    var scheme: String { get }
    var host: String { get }
    var subPath: String? { get }

    var httpHeaderFields: [String: String] { get }
    var dateEncodingStrategy: JSONEncoder.DateEncodingStrategy { get }
}

// MARK: - ApiJsonable: ApiDiscoverable

public protocol ApiJsonable: ApiDiscoverable {
    func request<T: Codable>(_ request: URLRequest,
                             success: ((T) -> Void)?,
                             failure: RequestFailure) -> FetchOperation?

    func request<T: Codable>(_ request: Request,
                             success: ((T) -> Void)?,
                             failure: RequestFailure) -> FetchOperation?
}

// MARK: - ApiJsonable (Defaults)

extension ApiJsonable {
    /// Starts an Api request and returns the queued `FetchOperation`.
    /// - Parameters:
    ///   - request: Defines the components of the HTTP request.
    ///   - success: Handler if the HTTP request succeeds.
    ///   - failure: Handler if the HTTP request fails.
    /// - Returns: A queued `FetchOperation` that can be manipulated from the call site. For example,
    /// the call site may decide the operation needs to be cancelled if the user navigates away
    /// from call site's context.
    public func request<T: Codable>(_ request: Request,
                                    success: ((T) -> Void)?,
                                    failure: RequestFailure) -> FetchOperation? {
        if let urlRequest = request.urlRequest(forApi: self) {
            return self.request(urlRequest, success: success, failure: failure)
        } else {
            return nil
        }
    }
}
