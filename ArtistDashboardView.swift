import SwiftUI

/// Dashboard shown to artists for managing their own bookings.
struct ArtistDashboardView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @StateObject private var bookingVM = BookingViewModel()

    private func formattedDate(_ timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(bookingVM.bookings) { booking in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("User: \(booking.userId)")
                        Text("Time: \(booking.time)")
                        Text("Booked: \(formattedDate(booking.createdAt))")
                        Text("Status: \(booking.status)")
                        HStack {
                            Button("Accept") {
                                Task {
                                    await bookingVM.updateBooking(booking, to: "accepted")
                                    await bookingVM.fetchBookings(artistId: authVM.user?.uid)
                                }
                            }
                            .disabled(booking.status == "accepted")

                            Button("Cancel") {
                                Task {
                                    await bookingVM.updateBooking(booking, to: "canceled")
                                    await bookingVM.fetchBookings(artistId: authVM.user?.uid)
                                }
                            }
                            .tint(.red)
                            .disabled(booking.status == "canceled")
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("My Bookings")
            .toolbar {
                Button("Sign Out") { authVM.signOut() }
            }
            .task {
                await bookingVM.fetchBookings(artistId: authVM.user?.uid)
            }
        }
    }
}
