import Foundation
import FirebaseAuth
import FirebaseFirestore

/// View model responsible for handling booking creation and fetching
/// reserved time slots for a particular artist.
@MainActor
final class TimeSelectionViewModel: ObservableObject {
    /// Set of booked slots (represented by hour integer) that have
    /// already been accepted by an admin.
    @Published var reservedSlots: Set<Int> = []
    @Published var error: String?
    @Published var bookingSuccess = false
    @Published var isCreating = false

    private let db = Firestore.firestore()

    /// Fetch all accepted bookings for the provided artist.
    /// - Parameter artistId: Identifier of the artist to filter bookings.
    func fetchReservedSlots(for artistId: Int) async {
        error = nil
        do {
            let snapshot = try await db.collection("bookings")
                .whereField("artistId", isEqualTo: artistId)
                .whereField("status", isEqualTo: "accepted")
                .getDocuments()
            let hours = snapshot.documents.compactMap { doc -> Int? in
                guard let timeString = doc.data()["time"] as? String else { return nil }
                return Int(timeString.prefix(2))
            }
            reservedSlots = Set(hours)
        } catch {
            self.error = error.localizedDescription
        }
    }

    /// Create a new booking with `pending` status.
    /// - Parameters:
    ///   - artistId: The selected artist identifier.
    ///   - slot: Hour value for the booking.
    func createBooking(for artistId: Int, slot: Int) async {
        guard let uid = Auth.auth().currentUser?.uid else {
            error = "User not logged in"
            return
        }
        isCreating = true
        error = nil
        let data: [String: Any] = [
            "userId": uid,
            "artistId": artistId,
            "time": String(format: "%02d:00", slot),
            "status": "pending"
        ]
        do {
            _ = try await db.collection("bookings").addDocument(data: data)
            bookingSuccess = true
            await fetchReservedSlots(for: artistId)
        } catch {
            self.error = error.localizedDescription
        }
        isCreating = false
    }
}
