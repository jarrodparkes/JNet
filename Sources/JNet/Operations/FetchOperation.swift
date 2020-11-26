import Foundation

// MARK: - Fetchable

protocol Fetchable: class {
    var request: URLRequest { get }
    var data: Data? { get set }
    var response: URLResponse? { get set }
    var error: Error? { get set }
}

// MARK: - FetchOperation: BaseOperation, Fetchable

public class FetchOperation: BaseOperation, Fetchable {

    // MARK: Properties

    private var task: URLSessionDataTaskProtocol?

    var data: Data?
    var response: URLResponse?
    var error: Error?
    var retries = 0

    var taskState: URLSessionTask.State {
        return task?.state ?? .suspended
    }

    let session: URLSessionProtocol
    let request: URLRequest
    let artificialDelay: TimeInterval = 0

    // MARK: Initializer

    public init(request: URLRequest, session: URLSessionProtocol) {
        self.request = request
        self.session = session
        super.init()
    }

    // MARK: Operation

    override public func start() {
        startRequest()
    }

    override public func cancel() {
        super.cancel()
        task?.cancel()
    }

    // MARK: Helpers

    func startRequest() {
        guard !isCancelled else { return }

        // setup task
        task = session.dataTaskWithRequest(request) { (data, response, error) in
            DispatchQueue.main.asyncAfter(deadline: .now() + self.artificialDelay) {
                self.finishRequest(data: data, response: response, error: error)
            }
        }

        // execute the network task
        state = .executing
        task?.resume()
    }

    func finishRequest(data: Data?, response: URLResponse?, error: Error?) {
        let successfulResponse = (response as? HTTPURLResponse)?.hasSuccessfulStatusCode ?? false
        let shouldRetry = !successfulResponse && retries > 0

        if shouldRetry {
            retries -= 1
            task?.cancel()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.startRequest()
            }
        } else {
            self.data = data
            self.response = response
            self.error = error
            state = .finished
        }
    }
}
