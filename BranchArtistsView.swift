import SwiftUI

/// Displays artists assigned to a particular branch along with their bookings.
struct BranchArtistsView: View {
    let location: Location
    @StateObject private var artistVM = ArtistViewModel()
    @StateObject private var bookingVM = BookingViewModel()
    @State private var selectedArtist: Artist?
    @State private var showingTimeSelection = false

    private func bookings(for artist: Artist) -> [Booking] {
        bookingVM.bookings.filter { $0.artistId == artist.id }
    }

    private func formattedDate(_ timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    var body: some View {
        List {
            ForEach(artistVM.artists.filter { $0.locationId == location.id }) { artist in
                Section(header: Text(artist.name)) {
                    ForEach(bookings(for: artist)) { booking in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Date: \(booking.date)")
                            Text("Time: \(booking.time)")
                            Text("Booked: \(formattedDate(booking.createdAt))")
                            Text("Status: \(booking.status)")
                        }
                    }
                    Button("Book time") {
                        selectedArtist = artist
                        showingTimeSelection = true
                    }
                }
            }
        }
        .navigationTitle(location.name)
        .sheet(isPresented: $showingTimeSelection) {
            if let artist = selectedArtist {
                TimeSelectionView(selectedArtist: artist.id)
            }
        }
        .task {
            await artistVM.fetchArtists()
            await bookingVM.fetchBookings()
        }
    }
}
