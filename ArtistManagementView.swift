import SwiftUI

/// View for admins to manage artists.
struct ArtistManagementView: View {
    @StateObject private var viewModel = ArtistViewModel()
    @State private var email = ""

    private func locationName(for id: Int) -> String {
        locations.first(where: { $0.id == id })?.name ?? String(id)
    }

    var body: some View {
        // Wrapping content in ``Form`` ensures the keyboard accessory
        // view is managed correctly and avoids Auto Layout warnings
        // when the text field becomes first responder on iPad/Mac.
        Form {
            Section(header: Text("Артистууд")) {
                ForEach(viewModel.artists) { artist in
                    HStack {
                            VStack(alignment: .leading) {
                                Text(artist.name)
                                if let location = artist.locationId {
                                    Text("Байршил: \(locationName(for: location))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            Spacer()
                            Menu {
                                ForEach(locations) { location in
                                    Button(location.name) {
                                        Task { await viewModel.assignArtist(artist.id, to: location.id) }
                                    }
                                }
                            } label: {
                                Image(systemName: "mappin.and.ellipse")
                            }
                            Button(role: .destructive) {
                                Task { await viewModel.removeArtist(artist) }
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                    }
                }

                Section(header: Text("Артист нэмэх")) {
                    TextField("Хэрэглэгчийн имэйл", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .textContentType(.emailAddress)
                    Button("Нэмэх") {
                        Task {
                            await viewModel.addArtist(email: email)
                            email = ""
                        }
                    }
                }
            if let error = viewModel.error {
                Section {
                    Text(error)
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Артистууд")
        .task { await viewModel.fetchArtists() }
    }
}
