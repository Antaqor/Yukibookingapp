import SwiftUI

/// View for admins to manage artists.
struct ArtistManagementView: View {
    @StateObject private var viewModel = ArtistViewModel()
    @State private var email = ""

    var body: some View {
        VStack {
            List {
                Section(header: Text("Artists")) {
                    ForEach(viewModel.artists) { artist in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(artist.name)
                                if let location = artist.locationId {
                                    Text("Location: \(location)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            Spacer()
                            Button(role: .destructive) {
                                Task { await viewModel.removeArtist(artist) }
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                    }
                }

                Section(header: Text("Add Artist")) {
                    TextField("User email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    Button("Add") {
                        Task {
                            await viewModel.addArtist(email: email)
                            email = ""
                        }
                    }
                }
            }
            if let error = viewModel.error {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .navigationTitle("Artists")
        .task { await viewModel.fetchArtists() }
    }
}
