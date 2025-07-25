import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        VStack(spacing: 16) {
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .textFieldStyle(.roundedBorder)

            SecureField("Password", text: $password)
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

            if authVM.isLoading { ProgressView() }
        }
        .padding()
    }
}

