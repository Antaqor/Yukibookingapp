import Foundation
import FirebaseFirestore

@MainActor
final class BookingViewModel: ObservableObject {
    @Published var bookings: [Booking] = []
    @Published var error: String?

    private let db = Firestore.firestore()

    /// Fetch all bookings for admin dashboard
    func fetchBookings() async {
        do {
            let snapshot = try await db.collection("bookings").getDocuments()
            let docs = snapshot.documents
            self.bookings = docs.map { doc in
                let data = doc.data()
                return Booking(
                    id: doc.documentID,
                    userId: data["userId"] as? String ?? "",
                    artistId: data["artistId"] as? Int ?? 0,
                    time: data["time"] as? String ?? "",
                    status: data["status"] as? String ?? "pending"
                )
            }
        } catch {
            self.error = error.localizedDescription
        }
    }

    /// Update the status of a booking document
    func updateBooking(_ booking: Booking, to status: String) async {
        do {
            try await db.collection("bookings").document(booking.id).updateData(["status": status])
            if let index = bookings.firstIndex(where: { $0.id == booking.id }) {
                bookings[index].status = status
            }
        } catch {
            self.error = error.localizedDescription
        }
    }
}
