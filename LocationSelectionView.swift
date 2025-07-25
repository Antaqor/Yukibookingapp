import SwiftUI

struct LocationSelectionView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @State private var selectedLocation: Location?
    @State private var isChoosingArtist = false


    var body: some View {
        VStack(spacing: 24) {
            Text("Салбараа сонгоно уу")
                .font(.system(size: 22, weight: .bold))
                .padding(.top, 32)

            ForEach(locations) { location in
                Button(action: { selectedLocation = location }) {
                    HStack {
                        Text(location.name)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(selectedLocation?.id == location.id ? .white : .primary)
                        Spacer()
                        if selectedLocation?.id == location.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedLocation?.id == location.id ? Color("AccentColor") : Color(.systemGray6))
                    )
                }
                .buttonStyle(.plain)
            }

            Spacer()

            Button(action: { isChoosingArtist = true }) {
                Text("Үргэлжлүүлэх")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity, minHeight: 50)
            }
            .background(selectedLocation == nil ? Color(.systemGray4) : Color("AccentColor"))
            .foregroundColor(.white)
            .cornerRadius(12)
            .disabled(selectedLocation == nil)
            .padding(.bottom, 24)
        }
        .padding(.horizontal, 16)
        .background(
            NavigationLink(
                destination: Group {
                    if let location = selectedLocation {
                        BranchArtistsView(location: location)
                    }
                },
                isActive: $isChoosingArtist
            ) {
                EmptyView()
            }
            .hidden()
        )
        .navigationTitle("Locations")
        .navigationBarTitleDisplayMode(.inline)
    }
}
