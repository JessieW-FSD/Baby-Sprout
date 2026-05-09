import SwiftUI
import SwiftData
import PhotosUI

struct AddCustomEventView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var entryToEdit: CustomEventEntry?
    private var isEditing: Bool { entryToEdit != nil }

    @State private var timestamp = Date()
    @State private var title = ""
    @State private var eventDescription = ""
    @State private var notes = ""
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var photoDataArray: [Data] = []
    @State private var showCamera = false

    private let presetTitles = ["Vomit", "Fever", "Rash", "Injury", "Doctor Visit", "Milestone"]
    private let maxPhotos = 5

    var body: some View {
        NavigationStack {
            Form {
                Section("Time") {
                    DatePicker("Time", selection: $timestamp, displayedComponents: [.date, .hourAndMinute])
                }

                Section("Event Type") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                        ForEach(presetTitles, id: \.self) { preset in
                            Button {
                                title = preset
                            } label: {
                                Text(preset)
                                    .font(.subheadline)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .frame(maxWidth: .infinity)
                                    .background(title == preset ? Color.accentColor : Color(.systemGray5))
                                    .foregroundStyle(title == preset ? .white : .primary)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)

                    TextField("Or enter custom event", text: $title)
                }

                Section("Description") {
                    TextField("What happened?", text: $eventDescription, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Photos") {
                    if photoDataArray.count < maxPhotos {
                        PhotosPicker(
                            selection: $selectedPhotos,
                            maxSelectionCount: maxPhotos - photoDataArray.count,
                            matching: .images
                        ) {
                            Label("Choose from Library", systemImage: "photo.on.rectangle.angled")
                        }
                        .onChange(of: selectedPhotos) { _, newItems in
                            guard !newItems.isEmpty else { return }
                            Task {
                                for item in newItems {
                                    if let data = try? await item.loadTransferable(type: Data.self),
                                       let compressed = compressImageData(data) {
                                        photoDataArray.append(compressed)
                                    }
                                }
                                selectedPhotos = []
                            }
                        }

                        Button {
                            showCamera = true
                        } label: {
                            Label("Take Photo", systemImage: "camera.fill")
                        }
                    }

                    if !photoDataArray.isEmpty {
                        Text("\(photoDataArray.count)/\(maxPhotos) photos")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(Array(photoDataArray.enumerated()), id: \.offset) { index, data in
                                    if let uiImage = UIImage(data: data) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 80, height: 80)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                            .overlay(alignment: .topTrailing) {
                                                Button {
                                                    photoDataArray.remove(at: index)
                                                } label: {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .foregroundStyle(.white, .red)
                                                        .font(.caption)
                                                }
                                                .offset(x: 4, y: -4)
                                            }
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }

                Section("Notes") {
                    TextField("Optional notes", text: $notes, axis: .vertical)
                        .lineLimit(3)
                }
            }
            .onAppear { populateFromEntry() }
            .navigationTitle(isEditing ? "Edit Event" : "Log Event")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .sheet(isPresented: $showCamera) {
                CameraPicker { image in
                    if let compressed = compressUIImage(image) {
                        photoDataArray.append(compressed)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func populateFromEntry() {
        guard let entry = entryToEdit else { return }
        timestamp = entry.timestamp
        title = entry.title
        eventDescription = entry.eventDescription
        photoDataArray = entry.photoDataArray
        notes = entry.notes
    }

    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        if let entry = entryToEdit {
            entry.timestamp = timestamp
            entry.title = trimmedTitle
            entry.eventDescription = eventDescription
            entry.photoDataArray = photoDataArray
            entry.notes = notes
        } else {
            let entry = CustomEventEntry(
                timestamp: timestamp,
                title: trimmedTitle,
                eventDescription: eventDescription,
                photoDataArray: photoDataArray,
                notes: notes
            )
            modelContext.insert(entry)
        }
        ReminderManager.reschedule()
        dismiss()
    }

    private func compressImageData(_ data: Data) -> Data? {
        guard let uiImage = UIImage(data: data) else { return nil }
        return compressUIImage(uiImage)
    }

    private func compressUIImage(_ uiImage: UIImage) -> Data? {
        let maxDimension: CGFloat = 1024
        let size = uiImage.size
        if size.width > maxDimension || size.height > maxDimension {
            let scale = maxDimension / max(size.width, size.height)
            let newSize = CGSize(width: size.width * scale, height: size.height * scale)
            let renderer = UIGraphicsImageRenderer(size: newSize)
            let resized = renderer.image { _ in
                uiImage.draw(in: CGRect(origin: .zero, size: newSize))
            }
            return resized.jpegData(compressionQuality: 0.7)
        }
        return uiImage.jpegData(compressionQuality: 0.7)
    }
}

struct CameraPicker: UIViewControllerRepresentable {
    var onImagePicked: (UIImage) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onImagePicked: onImagePicked)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onImagePicked: (UIImage) -> Void

        init(onImagePicked: @escaping (UIImage) -> Void) {
            self.onImagePicked = onImagePicked
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                onImagePicked(image)
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
