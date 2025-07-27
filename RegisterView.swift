import SwiftUI
import UIKit

struct RegisterView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @FocusState private var focus: Field?

    private enum Field { case name, phone, email, password, confirm }
    private func ascii(_ s: String) -> String { String(s.filter { $0.isASCII }) }

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.brand.opacity(0.12), Color.softBackground],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    Text("Yuki Salon")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.brand)
                        .padding(.top, 28)

                    SurfaceCard(title: "Create Account") {
                        VStack(spacing: 14) {

                            textField("Full Name",
                                      text: $name,
                                      field: .name,
                                      contentType: .name)
                                .submitLabel(.next)

                            textField("Phone Number",
                                      text: $phone,
                                      field: .phone,
                                      contentType: .telephoneNumber,
                                      keyboard: .phonePad,
                                      transform: { String($0.filter(\.isNumber)) }) // ✅ буцаадаг
                                .submitLabel(.next)

                            textField("Email",
                                      text: $email,
                                      field: .email,
                                      contentType: .emailAddress,
                                      keyboard: .emailAddress,
                                      transform: { ascii($0) }) // ✅ буцаадаг
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                                .submitLabel(.next)

                            secureField("Password (min 6 chars)",
                                        text: $password,
                                        field: .password)
                                .submitLabel(.next)

                            secureField("Confirm Password",
                                        text: $confirmPassword,
                                        field: .confirm)
                                .submitLabel(.go)
                                .onSubmit { register() }

                            if let error = authVM.error, !error.isEmpty {
                                Text(error)
                                    .foregroundColor(.red)
                                    .font(.footnote)
                            }

                            Button(action: register) {
                                Text("Register")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .buttonStyle(PrimaryButtonStyle())
                            .disabled(authVM.isLoading)
                        }
                    }

                    if authVM.isLoading { ProgressView() }

                    HStack(spacing: 6) {
                        Text("Already have an account?")
                            .foregroundColor(.secondary)
                        Button {
                            Haptics.tap()
                            dismiss()
                        } label: {
                            Text("Log In").fontWeight(.semibold)
                        }
                        .foregroundColor(.brand)
                    }
                    .padding(.horizontal, 16)

                    Spacer(minLength: 16)
                }
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .onAppear { focus = .name }
    }

    // MARK: - Actions
    private func register() {
        Task {
            await authVM.register(
                name: name,
                phone: phone,
                email: email,
                password: password,
                confirmPassword: confirmPassword
            )
            if authVM.error == nil { Haptics.success() }
        }
    }

    // MARK: - Styled text fields
    @ViewBuilder
    private func textField(
        _ placeholder: String,
        text: Binding<String>,
        field: Field,
        contentType: UITextContentType,
        keyboard: UIKeyboardType = .default,
        transform: ((String) -> String)? = nil   // <- String-г буцаана
    ) -> some View {
        TextField(placeholder, text: text)
            .keyboardType(keyboard)
            .textContentType(contentType)
            .focused($focus, equals: field)
            .onChange(of: text.wrappedValue) { _, new in
                if let transform { text.wrappedValue = transform(new) }
            }
            .padding(.horizontal, 12)
            .frame(height: 48)
            .background(Color.fieldBG)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(focus == field ? Color.brand : Color(.systemGray3),
                            lineWidth: focus == field ? 2 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private func secureField(
        _ placeholder: String,
        text: Binding<String>,
        field: Field
    ) -> some View {
        SecureField(placeholder, text: text)
            .textContentType(.newPassword)
            .focused($focus, equals: field)
            .padding(.horizontal, 12)
            .frame(height: 48)
            .background(Color.fieldBG)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(focus == field ? Color.brand : Color(.systemGray3),
                            lineWidth: focus == field ? 2 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
