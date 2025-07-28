import SwiftUI

struct EmailAuthView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var name = ""
    @State private var phone = ""

    // ``Form`` ensures the keyboard's accessory view is handled correctly
    // and prevents Auto Layout warnings on iPad/Mac Catalyst.
    var body: some View {
        Form {
            Section {
                TextField("Нэр", text: $name)
                TextField("Утас", text: $phone)
                    .keyboardType(.phonePad)
                TextField("Имэйл", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                SecureField("Нууц үг (хамгийн бага 6 тэмдэгт)", text: $password)
                SecureField("Нууц үг давтах", text: $confirmPassword)
            }

            if let error = authVM.error, !error.isEmpty {
                Section {
                    Text(error)
                        .foregroundColor(.red)
                }
            }

            Section {
                Button("Нэвтрэх") {
                    Task { await authVM.login(email: email, password: password) }
                }
                .buttonStyle(.borderedProminent)
                .disabled(authVM.isLoading)

                Button("Бүртгүүлэх") {
                    Task {
                        await authVM.register(name: name, phone: phone, email: email, password: password, confirmPassword: confirmPassword)
                    }
                }
                .buttonStyle(.bordered)
                .disabled(authVM.isLoading)

                if authVM.isLoading { ProgressView() }
            }
        }
        .padding(.vertical)
    }
}
