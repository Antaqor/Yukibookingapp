import SwiftUI

struct Artist: Identifiable {
    let id: Int
    let name: String
}

struct ArtistSelectionView: View {
    var selectedLocation: Location?
    @State private var selectedArtist: Artist?
    @State private var showBooking = false

    private let artists = [
        Artist(id: 1, name: "Ари"),
        Artist(id: 2, name: "Зулаа"),
        Artist(id: 3, name: "Болормаа")
    ]

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Artist-аа сонгоно уу")
                    .font(.system(size: 22, weight: .bold))
                    .padding(.top, 32)

                ForEach(artists) { artist in
                    Button(action: { selectedArtist = artist }) {
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

                if selectedArtist != nil {
                    Button(action: { showBooking = true }) {
                        Text("Цаг авах")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity, minHeight: 50)
                    }
                    .background(Color("AccentColor"))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal, 16)
            .sheet(isPresented: $showBooking) {
                if let artist = selectedArtist {
                    TimeSelectionView(selectedArtist: artist.id)
                }
            }
            .navigationTitle("Artist сонгох")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
