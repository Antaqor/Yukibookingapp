import Foundation
import FirebaseDatabase

@MainActor
final class BookingViewModel: ObservableObject {
    @Published var bookings: [Booking] = []
    @Published var error: String?

    private let db = Database.database().reference()

    /// Fetch bookings. If `artistId` is provided the list is filtered
    /// to only include bookings for that artist.
    func fetchBookings(artistId: String? = nil) async {
        error = nil
        do {
            let ref = db.child("bookings")
            let snapshot: DataSnapshot
            if let artistId {
                snapshot = try await ref
                    .queryOrdered(byChild: "artistId")
                    .queryEqual(toValue: artistId)
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
                    time: value["time"] as? String ?? "",
                    status: value["status"] as? String ?? "pending"
                )
                loaded.append(booking)
            }
            self.bookings = loaded
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
    func updateBooking(_ booking: Booking, to status: String) async {
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
