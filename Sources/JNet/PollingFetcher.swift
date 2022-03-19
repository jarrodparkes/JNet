import Foundation

// MARK: - PollingFetcherDelegate

public protocol PollingFetcherDelegate: AnyObject {
    func pollingFetcherFailed(tag: Int, statusCode: Int, error: Error)
    func pollingFetcherFetchedResponse(tag: Int, record: Codable)
}

// MARK: - PollingFetcher

/// An object which abstracts away the complexity of regularly polling an API endpoint.
open class PollingFetcher<RecordType: Codable> {

    // MARK: Properties

    private let api: ApiJsonable
    private let coreRequest: Request
    private let pollingInterval: TimeInterval

    /// An object that can handle the callbacks.
    public weak var delegate: PollingFetcherDelegate?

    /// An identifying tag.
    public var tag: Int = 0

    private var timer: DispatchSourceTimer?

    // MARK: Initializer

    /// Creates a `PollingFetcher` for a specific `ApiJsonable` path represented by a `Request`.
    /// - Parameters:
    ///   - api: An API identified by its base URL components.
    ///   - coreRequest: An API request, or endpoint, and its URL components.
    ///   - pollingInterval: The number of seconds between polls.
    public init(api: ApiJsonable, coreRequest: Request, pollingInterval: TimeInterval) {
        self.api = api
        self.coreRequest = coreRequest
        self.pollingInterval = pollingInterval
    }

    // MARK: Fetch

    /// Starts a recurring fetch request.
    public func fetch() {
        if timer == nil {
            createTimer()
        } else {
            resetTimer()
        }
    }

    /// Stops recurring fetch request.
    public func stop() {
        stopTimer()
    }

    // MARK: Timer

    private func createTimer() {
        timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
        timer?.schedule(deadline: .now(), repeating: pollingInterval)
        timer?.setEventHandler { [weak self] in
            guard let self = self else { return }
            self.request()
        }
        timer?.activate()
    }

    private func resetTimer() {
        timer?.schedule(deadline: .now(), repeating: pollingInterval)
    }

    private func stopTimer() {
        timer?.cancel()
        timer = nil
    }

    // MARK: Request

    private func request() {
        guard let urlRequest = computeUrlRequest() else { return }

        let success = { [weak self] (response: RecordType) in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.delegate?.pollingFetcherFetchedResponse(tag: self.tag, record: response)
            }
        }

        let failure = { [weak self] (statusCode: Int, error: Error) in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.delegate?.pollingFetcherFailed(tag: self.tag, statusCode: statusCode, error: error)
            }
        }

        _ = api.request(urlRequest, success: success, failure: failure)
    }

    // MARK: Extension Points

    /// Compute the core URL request. Next request headers and parameters will be applied after this
    /// called.
    /// - Returns: A URL request.
    open func computeUrlRequest() -> URLRequest? {
        return coreRequest.urlRequest(forApi: api)
    }
}
