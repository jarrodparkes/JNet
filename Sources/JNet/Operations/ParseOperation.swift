import Foundation

// MARK: - Decodable (Helper)

extension Decodable {
    /// Transforms raw `Data` into a `Decodable` object.
    /// - Parameters:
    ///   - decoder: A JSON decoder.
    ///   - data: The data to decode.
    /// - Throws: A `DecodingError` if the decoding fails.
    /// - Returns: A `Decodable` object that was represented by the raw `Data`.
    public static func jsonDecode(using decoder: JSONDecoder, from data: Data) throws -> Self? {
        return try decoder.decode(self, from: data)
    }
}

// MARK: - JSONDecoder (Helper)

extension JSONDecoder {
    /// Given a `Decodable.Type` and raw `Data`, transforms the raw data into a `Decodable` object.
    /// - Parameters:
    ///   - type: The type to use when decoding the raw data.
    ///   - data: The data to decode.
    /// - Throws: A `DecodingError` if the decoding fails.
    /// - Returns: A `Decodable` object that was represented by the raw `Data`.
    public func jsonDecode(_ type: Decodable.Type, from data: Data) throws -> Decodable? {
        return try type.jsonDecode(using: self, from: data)
    }
}

// MARK: - ParseOperation: BaseOperation

open class ParseOperation: BaseOperation {

    // MARK: Properties

    public var result: Any?
    public var response: URLResponse?
    public var error: Error?
    public let type: Decodable.Type

    open var computedError: Error {
        return error ?? ApiError.none
    }

    public var httpResponse: HTTPURLResponse? {
        return response as? HTTPURLResponse
    }

    public var request: URLRequest? {
        return (dependencies.first as? Fetchable)?.request
    }

    // MARK: Initializer

    public init(type: Decodable.Type) {
        self.type = type
        super.init()
    }

    // MARK: Operation

    override public func start() {
        guard !isCancelled else { return }

        state = .executing

        // capture the results of the results operation
        if let resultsOperation = dependencies.first as? Fetchable {
            response = resultsOperation.response

            if let error = resultsOperation.error {
                self.error = error
            } else if let data = resultsOperation.data {
                // if data was returned, try to parse it
                do {
                    try parseData(data)
                } catch {
                    self.error = error
                }
            } else {
                error = ApiError.missingResultsErrorAndData
            }
        } else {
            error = ApiError.missingResultsDependency
        }

        state = .finished
    }

    // MARK: Parse

    open func parseData(_ data: Data) throws {
        let decoder = JSONDecoder()
        result = try decoder.jsonDecode(type, from: data)
    }
}
