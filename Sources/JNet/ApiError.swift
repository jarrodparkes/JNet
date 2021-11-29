import Foundation

// MARK: - ApiError: Error

public enum ApiError: Error {
    case none
    case missingResultsErrorAndData
    case missingResultsDependency
    case unexpectedStatusCode(Int)
    case resultsResponseNilOrNotHTTP
    case requestFailed(String)
    case unauthorized(String)
    case unableToLoad
    case mockError
    case decodingError(DecodingError)
}

// MARK: - ApiError: LocalizedError

extension ApiError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .requestFailed(let errorString): return errorString
        case .mockError: return "It's an unhappy path mock error!"
        case .unableToLoad: return "Unable to load"
        case .unexpectedStatusCode(let code): return "Unexpected status code: \(code)"
        case .decodingError(let error): return "Decoding error: \(error.localizedDescription)"
        case .none: return "I haven't been implemented yet!"
        default: return nil
        }
    }

    public var failureReason: String? { return nil }
    public var recoverySuggestion: String? { return nil }
    public var helpAnchor: String? { return nil }
}

// MARK: - ApiError: CustomNSError

extension ApiError: CustomNSError {
    public static var errorDomain: String {
        return "api.error"
    }

    public var errorCode: Int {
        switch self {
        case .none: return 0
        case .missingResultsErrorAndData: return 1
        case .missingResultsDependency: return 2
        case .unexpectedStatusCode: return 3
        case .resultsResponseNilOrNotHTTP: return 4
        case .requestFailed: return 5
        case .unauthorized: return 6
        case .mockError: return 7
        case .unableToLoad: return 8
        case .decodingError: return 9
        }
    }
}
