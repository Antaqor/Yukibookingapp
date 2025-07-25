import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showRegister = false
    @State private var showResetAlert = false
    @State private var resetMessage = ""

    // Wrapping fields in ``Form`` helps avoid Auto Layout warnings
    // related to the keyboard's accessory view on iPad/macOS.
    var body: some View {
        Form {
            Section {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)

                SecureField("Password", text: $password)
                    .textContentType(.password)
            }

            if let error = authVM.error, !error.isEmpty {
                Section {
                    Text(error)
                        .foregroundColor(.red)
                }
            }

            Section {
                Button(action: {
                    Task { await authVM.login(email: email, password: password) }
                }) {
                    Text("Log In")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color("AccentColor"))
                .disabled(authVM.isLoading)

                Button("Forgot Password?") {
                    Task {
                        await authVM.resetPassword(email: email)
                        resetMessage = "If an account exists, a reset email has been sent."
                        showResetAlert = true
                    }
                }
                .font(.footnote)
                .padding(.top, -4)

                Button("Register") {
                    showRegister = true
                }
                .buttonStyle(.bordered)
                .tint(Color("AccentColor"))
                .sheet(isPresented: $showRegister) {
                    RegisterView().environmentObject(authVM)
                }

                if authVM.isLoading { ProgressView() }
            }
        }
        .padding(.vertical)
        .alert(resetMessage, isPresented: $showResetAlert) {
            Button("OK", role: .cancel) { }
        }
    }
}

