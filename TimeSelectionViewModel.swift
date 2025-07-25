import Foundation
import FirebaseAuth
import FirebaseDatabase

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

    private let db = Database.database().reference()

    /// Fetch all accepted bookings for the provided artist.
    /// - Parameter artistId: Identifier of the artist to filter bookings.
    func fetchReservedSlots(for artistId: Int) async {
        error = nil
        do {
            let snapshot = try await db.child("bookings")
                .queryOrdered(byChild: "artistId")
                .queryEqual(toValue: artistId)
                .getData()
            let hours = (snapshot.children.allObjects as? [DataSnapshot])?.compactMap { snap -> Int? in
                guard
                    let data = snap.value as? [String: Any],
                    data["status"] as? String == "accepted",
                    let timeString = data["time"] as? String
                else { return nil }
                return Int(timeString.prefix(2))
            } ?? []
            reservedSlots = Set(hours)
        } catch {
            // Firebase surfaces connectivity issues through ``URLError``.
            if let urlError = error as? URLError,
               urlError.code == .notConnectedToInternet {
                self.error = "Unable to fetch slots. Check your internet connection."
            } else {
                self.error = error.localizedDescription
            }
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
            let ref = db.child("bookings").childByAutoId()
            try await ref.setValue(data)
            bookingSuccess = true
            await fetchReservedSlots(for: artistId)
        } catch {
            // Surface network connectivity issues to the view.
            if let urlError = error as? URLError,
               urlError.code == .notConnectedToInternet {
                self.error = "Unable to create booking. Check your internet connection."
            } else {
                self.error = error.localizedDescription
            }
        }
        isCreating = false
    }
}
