import Foundation

// MARK: - UploadOperation: BaseOperation, Fetchable

public class UploadOperation: BaseOperation, Fetchable {

    // MARK: Properties

    var data: Data?
    var response: URLResponse?
    var error: Error?

    let session: URLSessionProtocol
    let request: URLRequest
    var task: URLSessionDataTaskProtocol?

    // MARK: Initializer

    public init(request: URLRequest,
                session: URLSessionProtocol,
                boundary: String,
                fileData: Data,
                method: String,
                parameters: [String: String] = [:]) {
        self.request = request
        self.session = session
        super.init()
        setup(boundary: boundary, fileData: fileData, method: method, parameters: parameters)
    }

    private func setup(boundary: String,
                       fileData: Data,
                       method: String,
                       parameters: [String: String] = [:]) {
        // SOURCE: stackoverflow.com/q/55361096 (file upload using multipart/form-data)
        var data = Data()

        // parameters
        for(key, value) in parameters {
            data.append("\r\n--\(boundary)\r\n")
            data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            data.append("\(value)")
        }

        // method
        data.append("\r\n--\(boundary)\r\n")
        data.append("Content-Disposition: form-data; name=\"_method\"\r\n\r\n")
        data.append(method)

        // file data
        data.append("\r\n--\(boundary)\r\n")
        data.append("Content-Disposition: form-data; name=\"file\"; filename=\"file\"\r\n")
        data.append("Content-Type: image/jpeg\r\n\r\n")
        data.append(fileData)

        // end of data
        data.append("\r\n--\(boundary)--\r\n")

        // create a network task
        task = session.uploadTaskWithRequest(request, data: data) { (data, response, error) in
            self.data = data
            self.response = response
            self.error = error
            self.state = .finished
        }
    }

    // MARK: Operation

    override public func start() {
        guard !isCancelled else { return }

        // execute the network task
        state = .executing
        task?.resume()
    }

    override public func cancel() {
        super.cancel()
        task?.cancel()
    }
}
