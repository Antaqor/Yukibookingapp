import Foundation
import FirebaseDatabase

@MainActor
final class BookingViewModel: ObservableObject {
    @Published var bookings: [Booking] = []
    @Published var error: String?

    private let db = Database.database().reference()

    /// Fetch all bookings for admin dashboard
    func fetchBookings() async {
        error = nil
        do {
            let snapshot = try await db.child("bookings").getData()
            var loaded: [Booking] = []
            for child in snapshot.children.allObjects as? [DataSnapshot] ?? [] {
                guard let value = child.value as? [String: Any] else { continue }
                let booking = Booking(
                    id: child.key,
                    userId: value["userId"] as? String ?? "",
                    artistId: value["artistId"] as? Int ?? 0,
                    time: value["time"] as? String ?? "",
                    status: value["status"] as? String ?? "pending"
                )
                loaded.append(booking)
            }
            self.bookings = loaded
        } catch {
            if let dbError = error as NSError?,
               dbError.domain == DatabaseErrorDomain,
               DatabaseErrorCode(rawValue: dbError.code) == .networkError {
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
            if let dbError = error as NSError?,
               dbError.domain == DatabaseErrorDomain,
               DatabaseErrorCode(rawValue: dbError.code) == .networkError {
                self.error = "Unable to update booking. Check your internet connection."
            } else {
                self.error = error.localizedDescription
            }
        }
    }
}
