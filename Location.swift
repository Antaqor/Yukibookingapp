import Foundation

/// Represents a salon branch/location.
struct Location: Identifiable {
    /// Unique numeric identifier used in the database
    let id: Int
    /// Display name for the location
    let name: String
}

/// Predefined list of all available locations used across the app.
let locations: [Location] = [
    Location(id: 1, name: "Их дэлгүүрийн баруун талд"),
    Location(id: 2, name: "Чингис зочид буудал"),
    Location(id: 3, name: "Санто Апартмент"),
    Location(id: 4, name: "VIP Center")
]
