import Foundation

/// Represents an artist account promoted by an admin.
struct Artist: Identifiable {
    /// Firebase UID of the artist user
    let id: String
    /// Display name of the artist
    let name: String
    /// Identifier of the branch/location the artist is assigned to
    let locationId: Int?
}
