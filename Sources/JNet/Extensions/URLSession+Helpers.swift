import Foundation

// MARK: - RequestResult

public typealias RequestResult = (Data?, URLResponse?, Error?) -> Void

// MARK: - URLSessionProtocol

public protocol URLSessionProtocol {
    func dataTaskWithRequest(_ request: URLRequest,
                             completionHandler: @escaping RequestResult) -> URLSessionDataTaskProtocol
    func dataTaskWithURL(_ url: URL,
                         completionHandler: @escaping RequestResult) -> URLSessionDataTaskProtocol
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

public protocol URLSessionDataTaskProtocol {
    
    // MARK: Properties
    
    var state: URLSessionTask.State { get }
    
    // MARK: Helpers
    
    func cancel()
    func resume()
}

// MARK: - URLSessionDataTask: URLSessionDataTaskProtocol

extension URLSessionDataTask: URLSessionDataTaskProtocol {}
