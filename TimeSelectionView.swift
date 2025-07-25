import SwiftUI

struct TimeSlot: Identifiable {
    let id: Int
    let time: String
}

struct TimeSelectionView: View {
    var selectedArtist: Int
    @State private var selectedSlot: Int?
    @State private var showConfirmation = false

    let timeSlots: [TimeSlot] = (9...18).map { hour in
        TimeSlot(id: hour, time: String(format: "%02d:00", hour))
    }

    var body: some View {
        VStack(spacing: 24) {
            Text("Цаг сонгоно уу")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top, 32)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 16)], spacing: 16) {
                ForEach(timeSlots) { slot in
                    Button(action: { selectedSlot = slot.id }) {
                        Text(slot.time)
                            .fontWeight(selectedSlot == slot.id ? .bold : .regular)
                            .foregroundColor(selectedSlot == slot.id ? .white : .primary)
                            .frame(width: 80, height: 40)
                            .background(selectedSlot == slot.id ? Color.accentColor : Color(.secondarySystemBackground))
                            .cornerRadius(10)
                            .shadow(color: selectedSlot == slot.id ? .gray.opacity(0.5) : .clear, radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)

            Spacer()

            Button("Баталгаажуулах") {
                showConfirmation = true
            }
            .disabled(selectedSlot == nil)
            .frame(maxWidth: .infinity)
            .padding()
            .background(selectedSlot == nil ? Color.gray.opacity(0.3) : Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)

            if showConfirmation {
                Text("Таны сонгосон цаг: \(selectedSlot != nil ? timeSlots.first { $0.id == selectedSlot }!.time : "")")
                    .font(.headline)
                    .foregroundColor(.green)
                    .transition(.slide)
            }
        }
        .navigationTitle("Цаг авах")
        .navigationBarTitleDisplayMode(.inline)
    }
}
