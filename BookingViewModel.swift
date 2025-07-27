import Foundation
import FirebaseDatabase

@MainActor
final class BookingViewModel: ObservableObject {
    @Published var bookings: [Booking] = []
    @Published var error: String?

    private let db = Database.database().reference()

    /// Fetch bookings. If `artistId` or `userId` is provided the list is
    /// filtered accordingly.
    func fetchBookings(artistId: String? = nil, userId: String? = nil) async {
        error = nil
        // Clear previously loaded results so switching between artists
        // doesn't display stale bookings when the fetch fails or is pending.
        bookings = []
        do {
            let ref = db.child("bookings")
            // Result from Realtime Database query. `DataSnapshot` represents
            // a single node returned from Firebase. Ensure the type name is
            // spelled correctly to avoid compilation errors.
            let snapshot: DataSnapshot
            if let artistId {
                snapshot = try await ref
                    .queryOrdered(byChild: "artistId")
                    .queryEqual(toValue: artistId)
                    .getData()
            } else if let userId {
                snapshot = try await ref
                    .queryOrdered(byChild: "userId")
                    .queryEqual(toValue: userId)
                    .getData()
            } else {
                snapshot = try await ref.getData()
            }
            var loaded: [Booking] = []
            for child in snapshot.children.allObjects as? [DataSnapshot] ?? [] {
                guard let value = child.value as? [String: Any] else { continue }
                let booking = Booking(
                    id: child.key,
                    userId: value["userId"] as? String ?? "",
                    artistId: value["artistId"] as? String ?? "",
                    date: value["date"] as? String ?? "",
                    time: value["time"] as? String ?? "",
                    createdAt: value["createdAt"] as? TimeInterval ?? 0,
                    status: value["status"] as? String ?? "pending"
                )
                loaded.append(booking)
            }
            self.bookings = loaded.sorted { $0.createdAt > $1.createdAt }
        } catch {
            // Attempt to surface a more friendly message when the
            // device has no internet connectivity. Firebase currently
            // reports this as a generic `URLError` from the URL loading
            // system so we check for it explicitly.
            if let urlError = error as? URLError,
               urlError.code == .notConnectedToInternet {
                self.error = "Unable to fetch bookings. Check your internet connection."
            } else {
                self.error = error.localizedDescription
            }
        }
    }

    /// Update the status of a booking document
    /// - Parameters:
    ///   - booking: The booking to update.
    ///   - status: New status string. Must not be empty.
    func updateBooking(_ booking: Booking, to status: String) async {
        guard !status.isEmpty else {
            error = "Invalid status"
            return
        }

        let ref = db.child("bookings").child(booking.id).child("status")
        do {
            try await ref.setValue(status)
            if let index = bookings.firstIndex(where: { $0.id == booking.id }) {
                bookings[index].status = status
            }
        } catch {
            // Similar to ``fetchBookings`` we try to detect if the
            // operation failed due to connectivity issues.
            if let urlError = error as? URLError,
               urlError.code == .notConnectedToInternet {
                self.error = "Unable to update booking. Check your internet connection."
            } else {
                self.error = error.localizedDescription
            }
        }
    }
}
