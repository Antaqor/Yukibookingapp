import Foundation
import FirebaseAuth
import FirebaseDatabase

/// View model responsible for handling booking creation and fetching
/// reserved time slots for a particular artist.
@MainActor
final class TimeSelectionViewModel: ObservableObject {
    /// Set of booked slots (represented by hour integer) that have
    /// already been requested (pending or accepted) for a single day.
    @Published var reservedSlots: Set<Int> = []
    /// Mapping between date string and all reserved hours for that day.
    @Published var weeklyReserved: [String: Set<Int>] = [:]
    @Published var error: String?
    @Published var bookingSuccess = false
    @Published var isCreating = false

    /// Number of days ahead to fetch bookings for. Default is one week.
    private var daysWindow: Int = 7

    private let db = Database.database().reference()
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    /// Fetch all non-canceled bookings for the provided artist on a given date.
    /// - Parameters:
    ///   - artistId: Identifier of the artist to filter bookings.
    ///   - date: Booking date in yyyy-MM-dd format.
    func fetchReservedSlots(for artistId: String, date: String) async {
        error = nil
        do {
            let snapshot = try await db.child("bookings")
                .queryOrdered(byChild: "artistId")
                .queryEqual(toValue: artistId)
                .getData()
            let hours = (snapshot.children.allObjects as? [DataSnapshot])?.compactMap { snap -> Int? in
                guard
                    let data = snap.value as? [String: Any],
                    data["status"] as? String != "canceled",
                    data["date"] as? String == date,
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

    /// Fetch bookings for the upcoming days and populate ``weeklyReserved``.
    /// Only bookings that have not been canceled are considered.
    /// - Parameters:
    ///   - artistId: Identifier of the artist.
    ///   - days: Number of days ahead to fetch.
    func fetchSchedule(for artistId: String, days: Int) async {
        error = nil
        weeklyReserved = [:]
        daysWindow = days
        do {
            // Fetch all bookings for the artist in a single query
            let snapshot = try await db.child("bookings")
                .queryOrdered(byChild: "artistId")
                .queryEqual(toValue: artistId)
                .getData()

            let validDates: [String] = (0..<days).compactMap { offset in
                guard let date = calendar.date(byAdding: .day, value: offset, to: calendar.startOfDay(for: Date())) else { return nil }
                return dateFormatter.string(from: date)
            }

            var schedule: [String: Set<Int>] = [:]
            for child in snapshot.children.allObjects as? [DataSnapshot] ?? [] {
                guard
                    let data = child.value as? [String: Any],
                    data["status"] as? String != "canceled",
                    let date = data["date"] as? String,
                    let time = data["time"] as? String,
                    let hour = Int(time.prefix(2)),
                    validDates.contains(date)
                else { continue }
                schedule[date, default: []].insert(hour)
            }
            weeklyReserved = schedule
        } catch {
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
    ///   - date: Booking date in yyyy-MM-dd format.
    ///   - slot: Hour value for the booking.
    func createBooking(for artistId: String, date: String, slot: Int) async {
        guard let uid = Auth.auth().currentUser?.uid else {
            error = "User not logged in"
            return
        }
        isCreating = true
        error = nil
        let data: [String: Any] = [
            "userId": uid,
            "artistId": artistId,
            "date": date,
            "time": String(format: "%02d:00", slot),
            "status": "pending",
            "createdAt": Date().timeIntervalSince1970
        ]
        do {
            let ref = db.child("bookings").childByAutoId()
            try await ref.setValue(data)
            bookingSuccess = true
            await fetchSchedule(for: artistId, days: daysWindow)
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
