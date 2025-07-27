import Foundation
import FirebaseAuth
import FirebaseDatabase

@MainActor
final class TimeSelectionViewModel: ObservableObject {
    @Published var reservedSlots: Set<Int> = []
    @Published var weeklyReserved: [String: Set<Int>] = [:]
    @Published var error: String?
    @Published var bookingSuccess = false
    @Published var isCreating = false

    private var daysWindow: Int = 7
    private let db = Database.database().reference()
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

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
                    data["artistId"] as? String == artistId,
                    data["status"] as? String != "canceled",
                    data["date"] as? String == date,
                    let timeString = data["time"] as? String
                else { return nil }
                return Int(timeString.prefix(2))
            } ?? []
            reservedSlots = Set(hours)
        } catch {
            if let urlError = error as? URLError, urlError.code == .notConnectedToInternet {
                self.error = "Unable to fetch slots. Check your internet connection."
            } else {
                self.error = error.localizedDescription
            }
        }
    }

    func fetchSchedule(for artistId: String, days: Int) async {
        error = nil
        weeklyReserved = [:]
        daysWindow = days
        do {
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
                    data["artistId"] as? String == artistId,
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
            if let urlError = error as? URLError, urlError.code == .notConnectedToInternet {
                self.error = "Unable to fetch slots. Check your internet connection."
            } else {
                self.error = error.localizedDescription
            }
        }
    }

    /// Create a new booking
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
            await removeBookedTime(from: artistId, at: slot)
            bookingSuccess = true
            await fetchSchedule(for: artistId, days: daysWindow)
        } catch {
            if let urlError = error as? URLError, urlError.code == .notConnectedToInternet {
                self.error = "Unable to create booking. Check your internet connection."
            } else {
                self.error = error.localizedDescription
            }
        }
        isCreating = false
    }

    private func removeBookedTime(from artistId: String, at time: Int) async {
        let artistRef = db.child("artists").child(artistId).child("availableTimes")
        do {
            let snapshot = try await artistRef.getData()
            var times = snapshot.value as? [Int] ?? []
            times.removeAll { $0 == time }
            try await artistRef.setValue(times)
        } catch {
            print("Failed to update artist times: \(error.localizedDescription)")
        }
    }
}
