import Foundation

// MARK: - UUIDCodable: Codable

public protocol UUIDCodable: Codable {
    var id: UUID { get }
}
