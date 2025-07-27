import SwiftUI

struct ArtistDashboardView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @StateObject private var bookingVM = BookingViewModel()
    @StateObject private var artistVM = ArtistViewModel()

    private func formattedDate(_ timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .short
        return f.string(from: date)
    }

    private func statusColor(for status: String) -> Color {
        switch status {
        case "accepted": return Color.green.opacity(0.2)
        case "canceled": return Color.red.opacity(0.2)
        default: return Color.orange.opacity(0.2)
        }
    }

    private func loadBookings() async {
        guard let uid = authVM.user?.uid, !uid.isEmpty else {
            print("‼️ No user is currently logged in!")
            return
        }
        print("✅ Logged-in ARTIST UID (should match Firebase): \(uid)")
        await bookingVM.fetchBookings(artistId: uid)
    }

    var body: some View {
        NavigationView {
            List {
                if bookingVM.bookings.isEmpty {
                    VStack(spacing: 16) {
                        Text("Танд одоогоор цаг захиалсан хэрэглэгч байхгүй байна.")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.vertical, 32)
                    }
                } else {
                    ForEach(bookingVM.bookings) { booking in
                        VStack(alignment: .leading, spacing: 8) {
                            Text("User: \(booking.userId)")
                            Text("Date: \(booking.date)")
                            Text("Time: \(booking.time)")
                            Text("Booked: \(formattedDate(booking.createdAt))")
                            Text("Status: \(booking.status)").fontWeight(.semibold)
                            HStack {
                                Button("Accept") {
                                    Task {
                                        await bookingVM.updateBooking(booking, to: "accepted")
                                        await loadBookings()
                                    }
                                }.disabled(booking.status == "accepted")

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
                }
            }
            .navigationTitle("My Bookings")
            .toolbar { Button("Sign Out") { authVM.signOut() } }
            .task {
                await artistVM.fetchArtists()
                await loadBookings()
            }
            .refreshable { await loadBookings() }
            .onAppear { Task { await loadBookings() } }
            .onChange(of: authVM.user?.uid ?? "") { _ in Task { await loadBookings() } }
        }
    }
}
