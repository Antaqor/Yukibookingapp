import SwiftUI

struct Location: Identifiable {
    let id: Int
    let name: String
}

struct LocationSelectionView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @State private var selectedLocation: Location?
    @State private var isChoosingArtist = false

    private let locations = [
        Location(id: 1, name: "Их дэлгүүрийн баруун талд"),
        Location(id: 2, name: "Чингис зочид буудал"),
        Location(id: 3, name: "Санто Апартмент"),
        Location(id: 4, name: "VIP Center")
    ]

    var body: some View {
        VStack(spacing: 20) {
            Text("Салбараа сонгоно уу")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 32)

            ForEach(locations) { location in
                Button(action: {
                    selectedLocation = location
                }) {
                    HStack {
                        Text(location.name)
                            .foregroundColor(selectedLocation?.id == location.id ? .white : .primary)
                        Spacer()
                        if selectedLocation?.id == location.id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(selectedLocation?.id == location.id ? Color.blue : Color.gray.opacity(0.2))
                    .cornerRadius(10)
                }
                .padding(.horizontal)
            }

            if selectedLocation != nil {
                Button("Үргэлжлүүлэх") {
                    isChoosingArtist = true
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 16)
            }

            Button("Sign Out") {
                authVM.signOut()
            }
            .padding(.top, 32)

            Spacer()
        }
        .sheet(isPresented: $isChoosingArtist) {
            ArtistSelectionView(selectedLocation: selectedLocation)
        }
        .navigationTitle("Locations")
        .navigationBarTitleDisplayMode(.inline)
    }
}
