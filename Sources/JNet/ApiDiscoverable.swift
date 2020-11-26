import Foundation

// MARK: - ApiDiscoverable

public protocol ApiDiscoverable: class {
    var scheme: String { get }
    var host: String { get }
    var subPath: String? { get }

    var dateEncodingStrategy: JSONEncoder.DateEncodingStrategy { get }
}

// MARK: - APIJsonable: ApiDiscoverable

public protocol APIJsonable: ApiDiscoverable {
    func request<T: Codable>(_ request: Request,
                             success: ((T) -> Void)?,
                             failure: RequestFailure) -> FetchOperation?
}
