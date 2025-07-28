import SwiftUI

struct BookingView: View {
    var artist: Artist?
    var location: Location?

    var body: some View {
        VStack(spacing: 24) {
            Text("Цаг захиалах")
                .font(.title)
            Text("Салбар: \(location?.name ?? "-")")
            Text("Артист: \(artist?.name ?? "-")")
            // Add booking form here
            Button("Хаах") { }
        }
        .padding()
    }
}
