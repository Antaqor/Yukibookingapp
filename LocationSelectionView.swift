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
        VStack(spacing: 24) {
            Text("Салбараа сонгоно уу")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top, 32)

            List {
                ForEach(locations) { location in
                    HStack {
                        Text(location.name)
                            .foregroundColor(selectedLocation?.id == location.id ? .white : .primary)
                        Spacer()
                        if selectedLocation?.id == location.id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(selectedLocation?.id == location.id ? Color.accentColor : Color.gray.opacity(0.2))
                    )
                    .onTapGesture { selectedLocation = location }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)

            Spacer()

            Button("Үргэлжлүүлэх") {
                isChoosingArtist = true
            }
            .buttonStyle(.borderedProminent)
            .disabled(selectedLocation == nil)
            .padding(.bottom, 24)
        }
        .sheet(isPresented: $isChoosingArtist) {
            ArtistSelectionView(selectedLocation: selectedLocation)
        }
        .navigationTitle("Locations")
        .navigationBarTitleDisplayMode(.inline)
    }
}
