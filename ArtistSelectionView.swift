import SwiftUI


struct ArtistSelectionView: View {
    var selectedLocation: Location?
    @State private var selectedArtist: Artist?
    @State private var showBooking = false
    @StateObject private var viewModel = ArtistViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Artist-аа сонгоно уу")
                    .font(.system(size: 22, weight: .bold))
                    .padding(.top, 32)

                ForEach(viewModel.artists.filter { artist in
                    if let location = selectedLocation {
                        return artist.locationId == location.id
                    }
                    return true
                }) { artist in
                    Button(action: {
                        selectedArtist = artist
                        showBooking = true
                    }) {
                        HStack {
                            Text(artist.name)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(selectedArtist?.id == artist.id ? .white : .primary)
                            Spacer()
                            if selectedArtist?.id == artist.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedArtist?.id == artist.id ? Color("AccentColor") : Color(.systemGray6))
                        )
                    }
                    .buttonStyle(.plain)
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .sheet(isPresented: $showBooking) {
                if let artist = selectedArtist {
                    TimeSelectionView(selectedArtist: artist.id)
                }
            }
            .task { await viewModel.fetchArtists() }
            .navigationTitle("Artist сонгох")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
