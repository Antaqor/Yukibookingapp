import Foundation

/// Represents an artist account promoted by an admin.
struct Artist: Identifiable {
    /// Firebase UID of the artist user
    let id: String
    /// Display name of the artist
    let name: String
    /// Identifier of the branch/location the artist is assigned to
    let locationId: Int?
    /// Available booking hours for the artist represented as 24h integers.
    /// When empty all default hours are available.
    let availableTimes: [Int]
}
