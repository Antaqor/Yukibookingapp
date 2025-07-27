import SwiftUI

struct TimeSlot: Identifiable { let id: Int; let time: String }

struct TimeSelectionView: View {
    var artist: Artist
    var daysToShow: Int = 7
    var onSuccess: (() -> Void)? = nil
    @State private var selectedSlot: Int?
    @State private var selectedDateString: String?
    @StateObject private var viewModel = TimeSelectionViewModel()
    @EnvironmentObject private var router: TabRouter
    @Environment(\.presentationMode) private var presentationMode

    private var timeSlots: [TimeSlot] {
        let hours = artist.availableTimes.isEmpty ? Array(9...18) : artist.availableTimes
        return hours.map { TimeSlot(id: $0, time: String(format: "%02d:00", $0)) }
    }
    private var dates: [Date] {
        let maxDays = max(1, daysToShow)
        return (0..<maxDays).compactMap { Calendar.current.date(byAdding: .day, value: $0, to: Date()) }
    }
    private var dateFormatter: DateFormatter { let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f }
    private var displayFormatter: DateFormatter { let f = DateFormatter(); f.dateStyle = .medium; return f }

    var body: some View {
        VStack(spacing: 24) {
            Text("Цаг сонгоно уу").font(.system(size: 22, weight: .bold)).padding(.top, 32)
            ScrollView {
                VStack(spacing: 32) {
                    ForEach(dates, id: \.self) { date in
                        let dateString = dateFormatter.string(from: date)
                        VStack(alignment: .leading, spacing: 12) {
                            Text(displayFormatter.string(from: date)).font(.headline).padding(.horizontal, 16)
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 16)], spacing: 16) {
                                ForEach(timeSlots) { slot in
                                    let isReserved = viewModel.weeklyReserved[dateString]?.contains(slot.id) ?? false
                                    Button {
                                        selectedDateString = dateString
                                        selectedSlot = slot.id
                                    } label: {
                                        Text(slot.time)
                                            .font(.system(size: 16, weight: selectedSlot == slot.id && selectedDateString == dateString ? .bold : .regular))
                                            .foregroundColor(isReserved ? .white : (selectedSlot == slot.id && selectedDateString == dateString ? .white : .primary))
                                            .frame(width: 80, height: 44)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(isReserved ? Color.red : (selectedSlot == slot.id && selectedDateString == dateString ? Color("AccentColor") : Color(.systemGray6)))
                                            )
                                    }
                                    .buttonStyle(.plain)
                                    .disabled(isReserved)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                }
            }

            Button {
                if let date = selectedDateString, let slot = selectedSlot {
                    Task { await viewModel.createBooking(for: artist.id, date: date, slot: slot) }
                }
            } label: {
                Text("Баталгаажуулах")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity, minHeight: 50)
            }
            .background(selectedSlot == nil ? Color(.systemGray4) : Color("AccentColor"))
            .foregroundColor(.white)
            .cornerRadius(12)
            .disabled(selectedSlot == nil)
            .padding(.horizontal, 16)

            if let error = viewModel.error { Text(error).foregroundColor(.red) }
            if viewModel.bookingSuccess {
                Text("Таны цаг амжилттай бүртгэгдлээ").font(.headline).foregroundColor(.green).transition(.slide)
            }
        }
        .navigationTitle("Цаг авах")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.fetchSchedule(for: artist.id, days: daysToShow) }
        .onChange(of: viewModel.bookingSuccess) { success in
            if success {
                onSuccess?()
                presentationMode.wrappedValue.dismiss()
                router.selection = 1
            }
        }
    }
}
