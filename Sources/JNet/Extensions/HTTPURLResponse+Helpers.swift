import Foundation

// MARK: - HTTPURLResponse (Helpers)

extension HTTPURLResponse {
    /// Is this response successful (2xx)?
    public var hasSuccessfulStatusCode: Bool {
        return (statusCode >= 200) && (statusCode <= 299)
    }
}
