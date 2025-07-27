import SwiftUI

/// Dashboard shown to artists for managing their own bookings.
struct ArtistDashboardView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @StateObject private var bookingVM = BookingViewModel()
    @StateObject private var artistVM = ArtistViewModel()

    /// Name of the location this artist is assigned to.
    private var locationName: String {
        guard
            let id = artistVM.artists.first(where: { $0.id == authVM.user?.uid })?.locationId,
            let location = locations.first(where: { $0.id == id })
        else { return "" }
        return location.name
    }

    private func formattedDate(_ timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    /// Maps booking status to a color used as row background.
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

    private func loadBookings() async {
        guard let uid = authVM.user?.uid else { return }
        await bookingVM.fetchBookings(artistId: uid)
    }

    var body: some View {
        NavigationView {
            List {
                // Show user's bookings first so artists immediately see their
                // upcoming schedule when opening the dashboard.
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
                                    await loadBookings()
                                }
                            }
                            .disabled(booking.status == "accepted")

                            Button("Cancel") {
                                Task {
                                    await bookingVM.updateBooking(booking, to: "canceled")
                                    await loadBookings()
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
                if !locationName.isEmpty {
                    Section {
                        Text("Location: \(locationName)")
                            .font(.headline)
                    }
                }
            }
            .navigationTitle("My Bookings")
            .toolbar {
                Button("Sign Out") { authVM.signOut() }
            }
            .task {
                await artistVM.fetchArtists()
                await loadBookings()
            }
            .refreshable {
                await loadBookings()
            }
            .onAppear {
                Task { await loadBookings() }
            }
            .onChange(of: authVM.user?.uid ?? "") { _ in
                Task { await loadBookings() }
            }
        }
    }
}
