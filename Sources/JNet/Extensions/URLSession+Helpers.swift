import Foundation

// MARK: - RequestResult

/// A request result handler which takes an optional raw `Data`, response, error as input.
public typealias RequestResult = (Data?, URLResponse?, Error?) -> Void

// MARK: - URLSessionProtocol

/// An object representing a `URLSession`. Useful for mocking.
public protocol URLSessionProtocol {
    /// Creates a task that retrieves the contents of a URL based on the specified URL request object,
    /// and calls a handler upon completion.
    /// - Parameters:
    ///   - request: A URL request object that provides the URL, cache policy, request type,
    ///   body data or body stream, and so on.
    ///   - completionHandler: The completion handler to call when the load request is complete.
    func dataTaskWithRequest(_ request: URLRequest,
                             completionHandler: @escaping RequestResult) -> URLSessionDataTaskProtocol

    /// Creates a task that retrieves the contents of the specified URL, then calls a handler upon completion.
    /// - Parameters:
    ///   - url: The URL to be retrieved.
    ///   - completionHandler: The completion handler to call when the load request is complete.
    func dataTaskWithURL(_ url: URL,
                         completionHandler: @escaping RequestResult) -> URLSessionDataTaskProtocol

    /// Creates a task that performs an HTTP request for the specified URL request object,
    /// uploads the provided data, and calls a handler upon completion.
    /// - Parameters:
    ///   - request: A URL request object that provides the URL, cache policy, request type, and so on.
    ///   - data: The body data for the request.
    ///   - completionHandler: The completion handler to call when the load request is complete.
    func uploadTaskWithRequest(_ request: URLRequest,
                               data: Data,
                               completionHandler: @escaping RequestResult) -> URLSessionDataTaskProtocol
}

// MARK: - URLSession: URLSessionProtocol

extension URLSession: URLSessionProtocol {
    public func dataTaskWithRequest(_ request: URLRequest,
                                    completionHandler: @escaping RequestResult) -> URLSessionDataTaskProtocol {
        return (dataTask(with: request, completionHandler: completionHandler)) as URLSessionDataTaskProtocol
    }

    public func dataTaskWithURL(_ url: URL,
                                completionHandler: @escaping RequestResult) -> URLSessionDataTaskProtocol {
        return (dataTask(with: url, completionHandler: completionHandler)) as URLSessionDataTaskProtocol
    }

    public func uploadTaskWithRequest(_ request: URLRequest,
                                      data: Data,
                                      completionHandler: @escaping RequestResult) -> URLSessionDataTaskProtocol {
        return (uploadTask(with: request,
                           from: data,
                           completionHandler: completionHandler)) as URLSessionDataTaskProtocol
    }
}

// MARK: - URLSessionDataTaskProtocol

/// An object representing a `URLSessionDataTask`. Useful for mocking.
public protocol URLSessionDataTaskProtocol {

    // MARK: Properties

    /// The current state of the task.
    var state: URLSessionTask.State { get }

    // MARK: Helpers

    /// Cancel the task.
    func cancel()
    /// Resume the task.
    func resume()
}

// MARK: - URLSessionDataTask: URLSessionDataTaskProtocol

extension URLSessionDataTask: URLSessionDataTaskProtocol {}
