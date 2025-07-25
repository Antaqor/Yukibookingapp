import SwiftUI

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
                .font(.system(size: 22, weight: .bold))
                .padding(.top, 32)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 16)], spacing: 16) {
                ForEach(timeSlots) { slot in
                    let isReserved = viewModel.reservedSlots.contains(slot.id)
                    Button(action: { selectedSlot = slot.id }) {
                        Text(slot.time)
                            .font(.system(size: 16, weight: selectedSlot == slot.id ? .bold : .regular))
                            .foregroundColor(isReserved ? .white : (selectedSlot == slot.id ? .white : .primary))
                            .frame(width: 80, height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        isReserved ? Color.red : (selectedSlot == slot.id ? Color("AccentColor") : Color(.systemGray6))
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(isReserved)
                }
            }
            .padding(.horizontal, 16)

            Spacer()

            Button(action: {
                if let slot = selectedSlot {
                    Task { await viewModel.createBooking(for: selectedArtist, slot: slot) }
                }
            }) {
                Text("Баталгаажуулах")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity, minHeight: 50)
            }
            .background(selectedSlot == nil ? Color(.systemGray4) : Color("AccentColor"))
            .foregroundColor(.white)
            .cornerRadius(12)
            .disabled(selectedSlot == nil)
            .padding(.horizontal, 16)

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
