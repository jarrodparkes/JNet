import Foundation

// MARK: - UUIDCodable: Codable

public protocol UUIDCodable: Codable {
    var id: UUID { get }
}

// MARK: - FetcherDelegate

public protocol FetcherDelegate: AnyObject {
    func fetcherStarted(fetcherTag: Int, firstPage: Bool)
    func fetcherFetchedNewRecords(fetcherTag: Int,
                                  records: [UUIDCodable],
                                  firstPage: Bool,
                                  fetchedAllRecords: Bool)
    func fetcherFailed(fetcherTag: Int, statusCode: Int, error: Error)
}

// MARK: - Fetcher

/// An object which abstracts away the complexity of requesting data from (paginated) API endpoints.
open class Fetcher<ResponseType: Codable, RecordType: UUIDCodable> {

    // MARK: Properties

    private let api: ApiJsonable

    private var coreRequest: Request
    private var currentRequest: FetchOperation?
    private var shouldResetOnLoad = true
    private var nextHTTPHeaders: [String: String?] = [:]
    private var nextQueryItems: [String: String?] = [:]

    private var _records: [RecordType] = []
    /// Ordered array of objects captured during fetches.
    public var records: [RecordType] { return _records }

    private var _fetchedAllRecords = false
    /// Have all possible records been fetched?
    public var fetchedAllRecords: Bool { return _fetchedAllRecords }

    /// Is the fetcher currently fetching objects?
    public var isFetching: Bool {
        if let currentRequest = currentRequest {
            return currentRequest.state == .executing
        } else {
            return false
        }
    }

    /// An object that can handle fetch callbacks.
    public weak var delegate: FetcherDelegate?

    /// An identifying tag.
    public var tag: Int = 0

    // MARK: Initializer

    /// Creates a `Fetcher` for a specific `ApiJsonable` path represented by `Request`.
    /// - Parameters:
    ///   - api: An API identified by its base URL components.
    ///   - coreRequest: An API request, or endpoint, and its URL components.
    public init(api: ApiJsonable, coreRequest: Request) {
        self.api = api
        self.coreRequest = coreRequest
    }

    // MARK: Fetch

    /// Starts a fetch request. If the request is for a paginated endpoint, then each subsequent call
    /// to this function will request the next page of records.
    public func fetch() {
        guard let nextRequest = nextRequest(), !_fetchedAllRecords else { return }

        if isFetching { cancelRequest() }

        let success = { [weak self] (response: ResponseType) in
            guard let self = self else { return }

            // update next request values
            self.nextHTTPHeaders = self.nextRequestHeaders(response: response,
                                                           headers: self.nextHTTPHeaders)
            self.nextQueryItems = self.nextRequestQueryItems(response: response,
                                                             items: self.nextQueryItems)
            let nextValuesEmpty = self.nextQueryItems.isEmpty && self.nextQueryItems.isEmpty

            // convert data to records
            let newRecords = self
                .responseToRecords(response: response)
                .unique

            // if no additional records, then everything has been fetched...
            if newRecords.isEmpty || nextValuesEmpty {
                self._fetchedAllRecords = true
            }

            // update records
            let firstPage = self.shouldResetOnLoad
            if firstPage {
                self._records = newRecords
                self.shouldResetOnLoad = false
            } else {
                self._records.append(contentsOf: newRecords)
            }

            // emit new records
            self.fetchedNewRecords(records: newRecords, firstPage: firstPage)
        }

        let failure = { [weak self] (statusCode: Int, error: Error) in
            guard let self = self else { return }
            self.fetchFailed(statusCode: statusCode, error: error)
        }

        fetchStarted(firstPage: shouldResetOnLoad)
        currentRequest = api.request(nextRequest, success: success, failure: failure)
    }

    // MARK: Request

    private func nextRequest() -> URLRequest? {
        let urlRequest = coreRequest.urlRequest(forApi: api)

        if let url = urlRequest?.url,
           var components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            components.scheme = url.scheme
            components.host = url.host
            components.path = url.path

            let existingItems = components.queryItems ?? []
            let nextItems = nextQueryItems.map { URLQueryItem(name: $0.key, value: $0.value) }
            components.queryItems = existingItems + nextItems

            if let nextUrl = components.url {
                var nextRequest = URLRequest(url: nextUrl)
                urlRequest?.allHTTPHeaderFields?.forEach { (key, value) in
                    nextRequest.addValue(value, forHTTPHeaderField: key)
                }
                nextHTTPHeaders.forEach { (key, value) in
                    if let value = value {
                        nextRequest.addValue(value, forHTTPHeaderField: key)
                    }
                }
                return finalizeUrlRequest(urlRequest: nextRequest, api: api)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }

    private func cancelRequest() {
        currentRequest?.cancel()
        currentRequest = nil
    }

    // MARK: Helpers

    /// Reset the fetcher such that the next `fetch()` will attempt to fetch a fresh record. If
    /// the request is for a paginated endpoint, then the next `fetch()` will be for the first page of records.
    public func reset() {
        cancelRequest()

        _fetchedAllRecords = false
        shouldResetOnLoad = true
        nextHTTPHeaders = [:]
        nextQueryItems = [:]
    }

    /// Return the underlying core request for this fetcher.
    /// - Returns: The core request for this fetcher.
    public func getRequest() -> Request {
        return coreRequest
    }

    /// Update the underlying core request for this fetcher.
    /// - Parameter coreRequest: New core request.
    public func setRequest(coreRequest: Request) {
        self.coreRequest = coreRequest
    }

    // MARK: Extension Points

    /// A callback which gives the fetcher a final chance to modify the URL request prior to
    /// it being issued.
    /// - Parameters:
    ///   - urlRequest: A URL request.
    ///   - api: An API with its own specific URL components.
    /// - Returns: The finalized URL request.
    open func finalizeUrlRequest(urlRequest: URLRequest, api: ApiJsonable) -> URLRequest {
        return urlRequest
    }

    /// Extracts an array of records from the top-level response. This is useful is an api endpoint
    /// returns a top-level JSON object containing an underlying array of objects.
    /// - Parameter response: The top-level response object.
    /// - Returns: An array of records to store for the latest fetch request.
    open func responseToRecords(response: ResponseType) -> [RecordType] { return [] }

    /// A callback when a new fetch starts.
    /// - Parameter firstPage: Is this fetch for the first page of records?
    open func fetchStarted(firstPage: Bool) {
        delegate?.fetcherStarted(fetcherTag: tag, firstPage: firstPage)
    }

    /// A callback when new records have been fetched.
    /// - Parameters:
    ///   - records: An array of newly fetched records.
    ///   - firstPage: Is this fetch for the first page of records?
    open func fetchedNewRecords(records: [RecordType], firstPage: Bool) {
        delegate?.fetcherFetchedNewRecords(fetcherTag: tag,
                                           records: records,
                                           firstPage: firstPage,
                                           fetchedAllRecords: fetchedAllRecords)
    }

    /// A callback when a fetch fails.
    /// - Parameters:
    ///   - statusCode: The HTTP status code for the failure (e.g. 422).
    ///   - error: The error for the failure.
    open func fetchFailed(statusCode: Int, error: Error) {
        delegate?.fetcherFailed(fetcherTag: tag, statusCode: statusCode, error: error)
    }

    /// Returns a dictionary of key/value pairs that will be used to set/override HTTP headers
    /// for the next fetch.
    /// - Parameters:
    ///   - response: The most recent top-level response object.
    ///   - headers: A dictionary of key/value pairs representing the HTTP headers used
    ///   for the last fetch.
    /// - Returns: A dictionary of key/value pairs representing HTTP headers to set/override
    /// for the next fetch.
    open func nextRequestHeaders(response: ResponseType,
                                 headers: [String: String?]) -> [String: String?] {
        return [:]
    }

    /// Returns dictionary of key/value that will be used to set/override query
    /// items the next fetch.
    /// - Parameters:
    ///   - response: The most recent top-level response object.
    ///   - items: A dictionary of key/value pairs representing the query items used
    ///   for the last fetch.
    /// - Returns: A dictionary of key/value pairs representing query items to set/override
    /// for the next fetch.
    open func nextRequestQueryItems(response: ResponseType,
                                    items: [String: String?]) -> [String: String?] {
        return [:]
    }
}
