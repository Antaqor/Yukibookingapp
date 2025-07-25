import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @StateObject private var bookingVM = BookingViewModel()
    @StateObject private var artistVM = ArtistViewModel()

    private func formattedDate(_ timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func artistName(for id: String) -> String {
        artistVM.artists.first(where: { $0.id == id })?.name ?? id
    }

    /// Returns a background color representing booking status.
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
        VStack {
            List {
                if let email = authVM.user?.email {
                    Section {
                        Text(email)
                            .font(.headline)
                    }
                }

            Section(header: Text("Миний цагууд")) {
                ForEach(bookingVM.bookings) { booking in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Artist: \(artistName(for: booking.artistId))")
                        Text("Date: \(booking.date)")
                        Text("Time: \(booking.time)")
                        Text("Booked: \(formattedDate(booking.createdAt))")
                        Text("Status: \(booking.status)")
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 8).fill(statusColor(for: booking.status)))
                }
            }

            Section {
                Button("Sign Out") {
                    authVM.signOut()
                }
            }
            }
            .listStyle(InsetGroupedListStyle())

            if let error = bookingVM.error {
                Text(error)
                    .foregroundColor(.red)
            }
        }
        .navigationTitle("Profile")
        .task {
            await artistVM.fetchArtists()
            await bookingVM.fetchBookings(userId: authVM.user?.uid)
        }
        .refreshable {
            await bookingVM.fetchBookings(userId: authVM.user?.uid)
        }
    }
}

#if DEBUG
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView().environmentObject(AuthViewModel())
    }
}
#endif
