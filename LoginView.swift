import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showRegister = false
    @State private var showResetAlert = false
    @State private var resetMessage = ""

    private func filterASCII(_ value: String) -> String {
        String(value.filter { $0.isASCII })
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()

                Text("Yuki Salon")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color("AccentColor"))

                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: email) { email = filterASCII($0) }

                    SecureField("Password", text: $password)
                        .textContentType(.password)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: password) { password = filterASCII($0) }
                }

                if let error = authVM.error, !error.isEmpty {
                    Text(error)
                        .foregroundColor(.red)
                }

                Button(action: {
                    Task { await authVM.login(email: email, password: password) }
                }) {
                    Text("Log In")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color("AccentColor"))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(authVM.isLoading)

                Button("Forgot Password?") {
                    Task {
                        await authVM.resetPassword(email: email)
                        resetMessage = "If an account exists, a reset email has been sent."
                        showResetAlert = true
                    }
                }
                .font(.footnote)

                Button("Register") { showRegister = true }
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .foregroundColor(Color("AccentColor"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color("AccentColor"), lineWidth: 1)
                    )
                    .sheet(isPresented: $showRegister) {
                        RegisterView().environmentObject(authVM)
                    }

                if authVM.isLoading { ProgressView() }

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 40)
            .background(Color.white.ignoresSafeArea())
            .alert(resetMessage, isPresented: $showResetAlert) {
                Button("OK", role: .cancel) { }
            }
        }
        .navigationBarHidden(true)
    }
}

