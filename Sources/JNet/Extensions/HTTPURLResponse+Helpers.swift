import Foundation

// MARK: - HTTPURLResponse (Helpers)

extension HTTPURLResponse {
    public var hasSuccessfulStatusCode: Bool {
        return (statusCode >= 200) && (statusCode <= 299)
    }
}
