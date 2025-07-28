import Foundation
import FirebaseDatabase

@MainActor
final class BookingViewModel: ObservableObject {
    @Published var bookings: [Booking] = []
    @Published var error: String?
    @Published var userPhones: [String: String] = [:]

    private let db = Database.database().reference()

    // — Helper: нэг удаа retry хийдэг getData
    private func getDataWithRetry(_ query: DatabaseQuery) async throws -> DataSnapshot {
        do {
            return try await query.getData()
        } catch {
            // оффлайн/кэш асуудал → онлайн болгож багахан хүлээгээд дахин оролдоно
            Database.database().goOnline()
            try? await Task.sleep(nanoseconds: 400_000_000) // 0.4s
            return try await query.getData()
        }
    }

    /// Fetch bookings. If `artistId` or `userId` is provided the list is filtered accordingly.
    /// Robust: server-side filter → хоосон/алдаа бол all fetch + client-side filter.
    func fetchBookings(artistId: String? = nil, userId: String? = nil) async {
        error = nil
        do {
            let ref = db.child("bookings")

            #if DEBUG
            print("⏳ fetchBookings(artistId: \(artistId ?? "nil"), userId: \(userId ?? "nil"))")
            #endif

            var serverRows: [DataSnapshot] = []

            // 1) Server-side filter оролдъё
            if let aId = artistId, !aId.isEmpty {
                let snap = try await getDataWithRetry(
                    ref.queryOrdered(byChild: "artistId").queryEqual(toValue: aId)
                )
                serverRows = (snap.children.allObjects as? [DataSnapshot]) ?? []
                #if DEBUG
                print("👀 server query (artistId) count:", snap.childrenCount)
                #endif
            } else if let uId = userId, !uId.isEmpty {
                let snap = try await getDataWithRetry(
                    ref.queryOrdered(byChild: "userId").queryEqual(toValue: uId)
                )
                serverRows = (snap.children.allObjects as? [DataSnapshot]) ?? []
                #if DEBUG
                print("👀 server query (userId) count:", snap.childrenCount)
                #endif
            } else {
                let snap = try await getDataWithRetry(ref)
                serverRows = (snap.children.allObjects as? [DataSnapshot]) ?? []
                #if DEBUG
                print("👀 server query (no filter) count:", serverRows.count)
                #endif
            }

            // 2) Хэрэв filter‑тэй мөртлөө хоосон бол: ALL → client-side filter
            var rows = serverRows
            if rows.isEmpty, (artistId != nil || userId != nil) {
                #if DEBUG
                print("⚠️ server empty → fallback to ALL + client-side filter")
                #endif
                let all = try await getDataWithRetry(ref)
                rows = (all.children.allObjects as? [DataSnapshot]) ?? []
            }

            // 3) Parse
            var loaded: [Booking] = []
            for child in rows {
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

            // 4) Client-side filter (extra safety)
            if let aId = artistId, !aId.isEmpty {
                loaded = loaded.filter { $0.artistId == aId }
            } else if let uId = userId, !uId.isEmpty {
                loaded = loaded.filter { $0.userId == uId }
            }

            self.bookings = loaded.sorted { $0.createdAt > $1.createdAt }

            // Load user phone numbers for displayed bookings
            var phones: [String: String] = [:]
            let ids = Set(self.bookings.map { $0.userId })
            for id in ids {
                do {
                    let snap = try await getDataWithRetry(
                        db.child("users").child(id).child("phone")
                    )
                    if let phone = snap.value as? String { phones[id] = phone }
                } catch {
                    // ignore individual failures
                }
            }
            self.userPhones = phones

            #if DEBUG
            print("✅ loaded bookings count:", self.bookings.count)
            #endif
        } catch {
            if let urlError = error as? URLError, urlError.code == .notConnectedToInternet {
                self.error = "Захиалгуудыг авах боломжгүй байна. Интернэтээ шалгана уу."
            } else {
                self.error = error.localizedDescription
            }
            #if DEBUG
            print("❌ fetchBookings error:", self.error ?? "unknown")
            #endif
        }
    }

    func updateBooking(_ booking: Booking, to status: String) async {
        guard !status.isEmpty else {
            error = "Буруу төлөв"
            return
        }
        let ref = db.child("bookings").child(booking.id).child("status")
        do {
            try await ref.setValue(status)
            if let index = bookings.firstIndex(where: { $0.id == booking.id }) {
                bookings[index].status = status
            }
        } catch {
            if let urlError = error as? URLError, urlError.code == .notConnectedToInternet {
                self.error = "Захиалгыг шинэчилж чадсангүй. Интернэтээ шалгана уу."
            } else {
                self.error = error.localizedDescription
            }
        }
    }

    /// Permanently remove a booking
    func deleteBooking(_ booking: Booking) async {
        let ref = db.child("bookings").child(booking.id)
        do {
            try await ref.removeValue()
            bookings.removeAll { $0.id == booking.id }
        } catch {
            if let urlError = error as? URLError, urlError.code == .notConnectedToInternet {
                self.error = "Захиалгыг устгаж чадсангүй. Интернэтээ шалгана уу."
            } else {
                self.error = error.localizedDescription
            }
        }
    }
}
