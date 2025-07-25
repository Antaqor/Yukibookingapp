import SwiftUI

/// Dashboard shown for admin users to manage bookings.
struct DashboardView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @StateObject private var bookingVM = BookingViewModel()

    var body: some View {
        NavigationView {
            List {
                ForEach(bookingVM.bookings) { booking in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("User: \(booking.userId)")
                        Text("Time: \(booking.time)")
                        Text("Status: \(booking.status)")
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
                    .padding(.vertical, 4)
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
