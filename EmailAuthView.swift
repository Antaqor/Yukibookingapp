import SwiftUI

struct EmailAuthView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var name = ""
    @State private var phone = ""

    var body: some View {
        VStack(spacing: 16) {
            TextField("Name", text: $name)
                .textFieldStyle(.roundedBorder)

            TextField("Phone", text: $phone)
                .keyboardType(.phonePad)
                .textFieldStyle(.roundedBorder)

            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .textFieldStyle(.roundedBorder)

            SecureField("Password (min 6 chars)", text: $password)
                .textFieldStyle(.roundedBorder)

            SecureField("Confirm Password", text: $confirmPassword)
                .textFieldStyle(.roundedBorder)

            if let error = authVM.error, !error.isEmpty {
                Text(error)
                    .foregroundColor(.red)
            }

            Button("Log In") {
                Task { await authVM.login(email: email, password: password) }
            }
            .buttonStyle(.borderedProminent)
            .disabled(authVM.isLoading)

            Button("Register") {
                Task {
                    await authVM.register(name: name, phone: phone, email: email, password: password, confirmPassword: confirmPassword)
                }
            }
            .buttonStyle(.bordered)
            .disabled(authVM.isLoading)

            if authVM.isLoading { ProgressView() }
        }
        .padding()
    }
}
