import SwiftUI

struct OnboardingView: View {
    @AppStorage("babyName") private var babyName = ""
    @AppStorage("babyDOB") private var babyDOBTimeInterval: Double = Date.now.timeIntervalSince1970

    @State private var nameInput = ""
    @State private var dobInput = Date()

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                Image(systemName: "baby.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.blue)

                Text("Welcome to EasyBaby")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Let's set up your baby's profile to get started.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                VStack(spacing: 16) {
                    TextField("Baby's name", text: $nameInput)
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    DatePicker("Date of birth", selection: $dobInput, in: ...Date.now, displayedComponents: .date)
                        .padding()
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)

                Spacer()

                Button {
                    babyName = nameInput.trimmingCharacters(in: .whitespaces)
                    babyDOBTimeInterval = dobInput.timeIntervalSince1970
                } label: {
                    Text("Get Started")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(nameInput.trimmingCharacters(in: .whitespaces).isEmpty ? .gray : .blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(nameInput.trimmingCharacters(in: .whitespaces).isEmpty)
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
        }
    }
}
