import SwiftUI

/// Displays artists assigned to a particular branch along with their bookings.
struct BranchArtistsView: View {
    let location: Location
    @StateObject private var artistVM = ArtistViewModel()
    @StateObject private var bookingVM = BookingViewModel()
    @State private var selectedArtist: Artist?
    @State private var showingTimeSelection = false

    /// Fetch bookings for the currently selected artist.
    private func loadBookings() async {
        guard let artist = selectedArtist else { return }
        await bookingVM.fetchBookings(artistId: artist.id)
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
            Section(header: Text("Artists")) {
                ForEach(artistVM.artists.filter { $0.locationId == location.id }) { artist in
                    Button(action: {
                        selectedArtist = artist
                        Task { await loadBookings() }
                    }) {
                        HStack {
                            Text(artist.name)
                            if selectedArtist?.id == artist.id {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }

            if let artist = selectedArtist {
                Section(header: Text("Bookings for \(artist.name)")) {
                    ForEach(bookingVM.bookings) { booking in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Date: \(booking.date)")
                            Text("Time: \(booking.time)")
                            Text("Booked: \(formattedDate(booking.createdAt))")
                            Text("Status: \(booking.status)")
                        }
                    }
                    Button("Book time") {
                        showingTimeSelection = true
                    }
                }
            }
        }
        .navigationTitle(location.name)
        .sheet(isPresented: $showingTimeSelection) {
            if let artist = selectedArtist {
                // Show only the next 3 days when booking from the admin panel
                TimeSelectionView(artist: artist, daysToShow: 3) {
                    Task { await loadBookings() }
                }
            }
        }
        .task {
            await artistVM.fetchArtists()
            if selectedArtist == nil,
               let first = artistVM.artists.first(where: { $0.locationId == location.id }) {
                selectedArtist = first
                await loadBookings()
            }
        }
    }
}
