import SwiftUI

struct RegisterView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var name = ""
    @State private var phone = ""

    // ``Form`` prevents layout issues when the keyboard and its
    // input assistant appear on screen.
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $name)
                TextField("Phone", text: $phone)
                    .keyboardType(.phonePad)
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                SecureField("Password (min 6 chars)", text: $password)
                    .textContentType(.newPassword)
                SecureField("Confirm Password", text: $confirmPassword)
                    .textContentType(.newPassword)
            }

            if let error = authVM.error, !error.isEmpty {
                Section {
                    Text(error)
                        .foregroundColor(.red)
                }
            }

            Section {
                Button(action: {
                    Task {
                        await authVM.register(name: name, phone: phone, email: email, password: password, confirmPassword: confirmPassword)
                    }
                }) {
                    Text("Register")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color("AccentColor"))
                .disabled(authVM.isLoading)

                if authVM.isLoading { ProgressView() }
            }
        }
        .padding(.vertical)
        .onAppear {
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        }
    }
}

