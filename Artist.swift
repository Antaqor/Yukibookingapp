import Foundation

/// Represents an artist account promoted by an admin.
struct Artist: Identifiable {
    /// Firebase UID of the artist user
    let id: String
    /// Display name of the artist
    let name: String
}
