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
            VStack(spacing: 16) {
                Text("Artist-аа сонгоно уу")
                    .font(.headline)
                ForEach(artists) { artist in
                    Button(action: {
                        selectedArtist = artist
                    }) {
                        HStack {
                            Text(artist.name)
                                .foregroundColor(selectedArtist?.id == artist.id ? .white : .primary)
                            Spacer()
                            if selectedArtist?.id == artist.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                        .background(selectedArtist?.id == artist.id ? Color.purple : Color.gray.opacity(0.2))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                if selectedArtist != nil {
                    Button("Цаг авах") {
                        showBooking = true
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top)
                }
                Spacer()
            }
            .navigationTitle("Artist сонгох")
            // Optionally: .sheet(isPresented: $showBooking) { ... }
        }
    }
}
