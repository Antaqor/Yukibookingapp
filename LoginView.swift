import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showRegister = false
    @State private var showResetAlert = false
    @State private var resetMessage = ""

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

        Button("Forgot Password?") {
            Task {
                await authVM.resetPassword(email: email)
                resetMessage = "If an account exists, a reset email has been sent."
                showResetAlert = true
            }
        }
        .font(.footnote)
        .padding(.top, -8)

        Button("Register") {
            showRegister = true
        }
        .buttonStyle(.bordered)
        .sheet(isPresented: $showRegister) {
            RegisterView().environmentObject(authVM)
        }

        if authVM.isLoading { ProgressView() }
        }
        .padding()
        .alert(resetMessage, isPresented: $showResetAlert) {
            Button("OK", role: .cancel) { }
        }
    }
}

