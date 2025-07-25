import SwiftUI

struct RegisterView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var name = ""
    @State private var phone = ""

    private func filterASCII(_ value: String) -> String {
        String(value.filter { $0.isASCII })
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()

                Text("Create Account")
                    .font(.system(size: 28, weight: .bold))

                VStack(spacing: 16) {
                    TextField("Name", text: $name)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: name) { name = filterASCII($0) }

                    TextField("Phone", text: $phone)
                        .keyboardType(.phonePad)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: phone) { phone = String($0.filter { $0.isNumber }) }

                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: email) { email = filterASCII($0) }

                    SecureField("Password (min 6 chars)", text: $password)
                        .textContentType(.newPassword)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: password) { password = filterASCII($0) }

                    SecureField("Confirm Password", text: $confirmPassword)
                        .textContentType(.newPassword)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: confirmPassword) { confirmPassword = filterASCII($0) }
                }

                if let error = authVM.error, !error.isEmpty {
                    Text(error)
                        .foregroundColor(.red)
                }

                Button(action: {
                    Task {
                        await authVM.register(name: name, phone: phone, email: email, password: password, confirmPassword: confirmPassword)
                    }
                }) {
                    Text("Register")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color("AccentColor"))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(authVM.isLoading)

                if authVM.isLoading { ProgressView() }

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 40)
            .background(Color.white.ignoresSafeArea())
            .onAppear {
                UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            }
        }
        .navigationBarHidden(true)
    }
}

