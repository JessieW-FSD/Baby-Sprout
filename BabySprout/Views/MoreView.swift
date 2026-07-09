import SwiftUI

struct MoreView: View {
    @AppStorage(AppStorageKeys.dayStartHour) private var dayStartHour = 8
    @AppStorage(AppStorageKeys.babyName) private var babyName = ""
    @AppStorage(AppStorageKeys.babyDOB) private var babyDOBTimeInterval: Double = Date.now.timeIntervalSince1970
    @AppStorage(AppStorageKeys.reminderEnabled) private var reminderEnabled = true
    @State private var showEditProfile = false

    var body: some View {
        NavigationStack {
            List {
                Section("Baby Profile") {
                    LabeledContent("Name", value: babyName)
                    LabeledContent("Date of birth") {
                        Text(Date(timeIntervalSince1970: babyDOBTimeInterval), format: .dateTime.month().day().year())
                    }
                    Button("Edit Profile") {
                        showEditProfile = true
                    }
                }

                NavigationLink {
                    FoodListView()
                } label: {
                    Label("Food", systemImage: "fork.knife")
                }

                NavigationLink {
                    SupplementListView()
                } label: {
                    Label("Supplements", systemImage: "pill.fill")
                }

                NavigationLink {
                    GrowthListView()
                } label: {
                    Label("Growth", systemImage: "chart.bar.fill")
                }

                NavigationLink {
                    CustomEventListView()
                } label: {
                    Label("Events", systemImage: "note.text")
                }

                NavigationLink {
                    ExportView()
                } label: {
                    Label("Export Data", systemImage: "square.and.arrow.up")
                }

                Section("Settings") {
                    Picker("Day starts at", selection: $dayStartHour) {
                        ForEach(0..<24, id: \.self) { hour in
                            Text(formatHour(hour)).tag(hour)
                        }
                    }
                    Toggle("4-hour reminder", isOn: $reminderEnabled)
                        .onChange(of: reminderEnabled) { _, enabled in
                            if enabled {
                                ReminderManager.reschedule()
                            } else {
                                ReminderManager.cancel()
                            }
                        }
                }
            }
            .navigationTitle("More")
            .sheet(isPresented: $showEditProfile) {
                EditProfileView()
            }
        }
    }

    private func formatHour(_ hour: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:00 a"
        guard let date = Calendar.current.date(from: DateComponents(hour: hour)) else { return "\(hour):00" }
        return formatter.string(from: date)
    }
}

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage(AppStorageKeys.babyName) private var babyName = ""
    @AppStorage(AppStorageKeys.babyDOB) private var babyDOBTimeInterval: Double = Date.now.timeIntervalSince1970

    @State private var nameInput = ""
    @State private var dobInput = Date()
    @State private var showConfirmation = false

    var hasChanges: Bool {
        nameInput.trimmingCharacters(in: .whitespaces) != babyName
            || abs(dobInput.timeIntervalSince1970 - babyDOBTimeInterval) > 60
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Baby Profile") {
                    HStack {
                        Text("Name")
                        Spacer()
                        TextField("Baby's name", text: $nameInput)
                            .multilineTextAlignment(.trailing)
                    }
                    DatePicker("Date of birth", selection: $dobInput, in: ...Date.now, displayedComponents: .date)
                }
            }
            .navigationTitle("Edit Profile")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        showConfirmation = true
                    }
                    .disabled(!hasChanges || nameInput.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .alert("Update Profile?", isPresented: $showConfirmation) {
                Button("Save", role: .destructive) {
                    babyName = nameInput.trimmingCharacters(in: .whitespaces)
                    babyDOBTimeInterval = dobInput.timeIntervalSince1970
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will update your baby's profile to \"\(nameInput.trimmingCharacters(in: .whitespaces))\".")
            }
            .onAppear {
                nameInput = babyName
                dobInput = Date(timeIntervalSince1970: babyDOBTimeInterval)
            }
        }
    }
}
