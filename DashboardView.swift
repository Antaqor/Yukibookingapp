import SwiftUI

/// Dashboard shown for admin users to manage bookings.
struct DashboardView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @StateObject private var bookingVM = BookingViewModel()

    private func formattedDate(_ timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    /// Maps a booking status string to a background color.
    private func statusColor(for status: String) -> Color {
        switch status {
        case "accepted":
            return Color.green.opacity(0.2)
        case "canceled":
            return Color.red.opacity(0.2)
        default:
            return Color.orange.opacity(0.2)
        }
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(bookingVM.bookings) { booking in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("User: \(booking.userId)")
                        Text("Date: \(booking.date)")
                        Text("Time: \(booking.time)")
                        Text("Booked: \(formattedDate(booking.createdAt))")
                        Text("Status: \(booking.status)")
                            .fontWeight(.semibold)
                        HStack {
                            Button("Accept") {
                                Task {
                                    await bookingVM.updateBooking(booking, to: "accepted")
                                    await bookingVM.fetchBookings()
                                }
                            }
                            .disabled(booking.status == "accepted")

                            Button("Cancel") {
                                Task {
                                    await bookingVM.updateBooking(booking, to: "canceled")
                                    await bookingVM.fetchBookings()
                                }
                            }
                            .tint(.red)
                            .disabled(booking.status == "canceled")
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 4)
                    .background(RoundedRectangle(cornerRadius: 8).fill(statusColor(for: booking.status)))
                }
            }
            .navigationTitle("Dashboard")
            .toolbar {
                Button("Sign Out") { authVM.signOut() }
            }
            .task { await bookingVM.fetchBookings() }
        }
    }
}
