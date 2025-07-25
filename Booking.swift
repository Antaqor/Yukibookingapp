import Foundation

/// Represents a single booking made by a user.
struct Booking: Identifiable {
    /// Unique booking identifier from Realtime Database
    let id: String
    /// UID of the user who created the booking
    let userId: String
    /// The artist identifier (Firebase UID)
    let artistId: String
    /// Booking date in yyyy-MM-dd format
    let date: String
    /// Time in HH:mm format
    let time: String
    /// Timestamp when the booking was created
    let createdAt: TimeInterval
    /// Current status: pending/accepted/canceled
    var status: String
}
