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
                    Text("Юки салон")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.brand)
                        .padding(.top, 28)

                    SurfaceCard(title: "Бүртгэл үүсгэх") {
                        VStack(spacing: 14) {

                            textField("Бүтэн нэр",
                                      text: $name,
                                      field: .name,
                                      contentType: .name)
                                .submitLabel(.next)

                            textField("Утасны дугаар",
                                      text: $phone,
                                      field: .phone,
                                      contentType: .telephoneNumber,
                                      keyboard: .phonePad,
                                      transform: { String($0.filter(\.isNumber)) }) // ✅ буцаадаг
                                .submitLabel(.next)

                            textField("Имэйл",
                                      text: $email,
                                      field: .email,
                                      contentType: .emailAddress,
                                      keyboard: .emailAddress,
                                      transform: { ascii($0) }) // ✅ буцаадаг
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                                .submitLabel(.next)

                            secureField("Нууц үг (хамгийн бага 6 тэмдэгт)",
                                        text: $password,
                                        field: .password)
                                .submitLabel(.next)

                            secureField("Нууц үг давтах",
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
                                Text("Бүртгүүлэх")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .buttonStyle(PrimaryButtonStyle())
                            .disabled(authVM.isLoading)
                        }
                    }

                    if authVM.isLoading { ProgressView() }

                    HStack(spacing: 6) {
                        Text("Өмнө нь бүртгүүлсэн үү?")
                            .foregroundColor(.secondary)
                        Button {
                            Haptics.tap()
                            dismiss()
                        } label: {
                            Text("Нэвтрэх").fontWeight(.semibold)
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
