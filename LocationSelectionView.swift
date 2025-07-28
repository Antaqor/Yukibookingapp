import SwiftUI

/// Location selection screen used by regular users.
///
/// The next step (artist selection) is now triggered directly by tapping a
/// location row rather than pressing a separate continue button.
struct LocationSelectionView: View {
    @EnvironmentObject private var authVM: AuthViewModel

    var body: some View {
        VStack(spacing: 24) {
            Text("Салбараа сонгоно уу")
                .font(.system(size: 22, weight: .bold))
                .padding(.top, 32)

            // Each location row navigates immediately to artist selection
            // eliminating the need for a "Үргэлжлүүлэх" button.
            ForEach(locations) { location in
                NavigationLink(destination: ArtistSelectionView(selectedLocation: location)) {
                    HStack {
                        Text(location.name)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                }
                .buttonStyle(.plain)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .navigationTitle("Салбарууд")
        .navigationBarTitleDisplayMode(.inline)
    }
}
