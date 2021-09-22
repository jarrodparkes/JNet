import Foundation

// MARK: - Fetcher

class Fetcher<WrapperType: Codable, RecordType: Codable> {

    // MARK: Properties

    private let api: APIJsonable

    private var coreRequest: Request
    private var currentRequest: FetchOperation?
    private var shouldResetOnLoad = true
    private var nextHTTPHeaders: [String: String?] = [:]
    private var nextQueryItems: [String: String?] = [:]

    private var _records: [RecordType] = []
    var records: [RecordType] { return _records }

    private var _fetchedAllRecords = false
    var fetchedAllRecords: Bool { return _fetchedAllRecords }

    var isFetching: Bool {
        if let currentRequest = currentRequest {
            return currentRequest.state == .executing
        } else {
            return false
        }
    }

    // MARK: Initializer

    init(api: APIJsonable, coreRequest: Request) {
        self.api = api
        self.coreRequest = coreRequest
    }

    // MARK: Fetch

    func fetch() {
        guard let nextRequest = nextRequest(), !_fetchedAllRecords else { return }

        if isFetching { cancelRequest() }

        let success = { [weak self] (response: WrapperType) in
            guard let self = self else { return }

            // update next request values
            self.nextHTTPHeaders = self.nextRequestHeaders(response: response,
                                                           headers: self.nextHTTPHeaders)
            self.nextQueryItems = self.nextRequestQueryItems(response: response,
                                                             items: self.nextQueryItems)
            let nextValuesEmpty = self.nextQueryItems.isEmpty && self.nextQueryItems.isEmpty

            // convert data to records
            let newRecords = self.dataToRecords(response: response)

            // no more records or next records, then everything has been fetched...
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
        let urlRequest = coreRequest.urlRequest(forAPI: api)

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
                return nextRequest
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

    func reset() {
        cancelRequest()

        _fetchedAllRecords = false
        shouldResetOnLoad = true
        nextHTTPHeaders = [:]
        nextQueryItems = [:]
    }

    func getRequest() -> Request {
        return coreRequest
    }

    func setRequest(coreRequest: Request) {
        self.coreRequest = coreRequest
    }

    // MARK: Extension Points

    func dataToRecords(response: WrapperType) -> [RecordType] { return [] }

    func fetchStarted(firstPage: Bool) {}
    func fetchedNewRecords(records: [RecordType], firstPage: Bool) {}
    func fetchFailed(statusCode: Int, error: Error) {}

    func nextRequestHeaders(response: WrapperType,
                            headers: [String: String?]) -> [String: String?] {
        return [:]
    }

    func nextRequestQueryItems(response: WrapperType,
                               items: [String: String?]) -> [String: String?] {
        return [:]
    }
}
