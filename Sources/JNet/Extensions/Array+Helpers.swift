import Foundation

// MARK: - Array (Helpers)

extension Array where Element: UUIDCodable {
    /// Returns unique elements identified by their UUID.
    public var unique: [Element] {
        var uniqueValues: [Element] = []
        var uniqueIds: [UUID] = []

        forEach { item in
            guard !uniqueIds.contains(item.id) else { return }
            uniqueIds.append(item.id)
            uniqueValues.append(item)
        }

        return uniqueValues
    }
}
