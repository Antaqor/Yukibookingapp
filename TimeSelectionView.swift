import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct TimeSlot: Identifiable {
    let id: Int
    let time: String
}

struct TimeSelectionView: View {
    var selectedArtist: Int
    @State private var selectedSlot: Int?
    @StateObject private var viewModel = TimeSelectionViewModel()

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
                    let isReserved = viewModel.reservedSlots.contains(slot.id)
                    Button(action: { selectedSlot = slot.id }) {
                        Text(slot.time)
                            .fontWeight(selectedSlot == slot.id ? .bold : .regular)
                            .foregroundColor(isReserved ? .white : (selectedSlot == slot.id ? .white : .primary))
                            .frame(width: 80, height: 40)
                            .background(
                                isReserved ? Color.red : (selectedSlot == slot.id ? Color.accentColor : Color(.secondarySystemBackground))
                            )
                            .cornerRadius(10)
                            .shadow(color: selectedSlot == slot.id ? .gray.opacity(0.5) : .clear, radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(.plain)
                    .disabled(isReserved)
                }
            }
            .padding(.horizontal)

            Spacer()

            Button("Баталгаажуулах") {
                if let slot = selectedSlot {
                    Task { await viewModel.createBooking(for: selectedArtist, slot: slot) }
                }
            }
            .disabled(selectedSlot == nil)
            .frame(maxWidth: .infinity)
            .padding()
            .background(selectedSlot == nil ? Color.gray.opacity(0.3) : Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)

            if let error = viewModel.error {
                Text(error)
                    .foregroundColor(.red)
            }

            if viewModel.bookingSuccess {
                Text("Таны цаг амжилттай бүртгэгдлээ")
                    .font(.headline)
                    .foregroundColor(.green)
                    .transition(.slide)
            }
        }
        .navigationTitle("Цаг авах")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.fetchReservedSlots(for: selectedArtist)
        }
    }
}
