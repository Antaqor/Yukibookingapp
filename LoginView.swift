// LoginView.swift
import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showRegister = false
    @State private var showResetAlert = false
    @State private var resetMessage = ""
    @FocusState private var focus: Field?

    private enum Field { case email, password }
    /// Enables the login button only when the user has entered what looks
    /// like a valid email and a sufficiently long password. Trimming helps
    /// avoid accidental spaces that would otherwise break authentication.
    private var isLoginEnabled: Bool {
        email.trimmingCharacters(in: .whitespacesAndNewlines).contains("@") &&
        password.trimmingCharacters(in: .whitespacesAndNewlines).count >= 6
    }
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

                    SurfaceCard(title: "Дахин тавтай морил") {
                        VStack(spacing: 14) {
                            // Email
                            TextField("Имэйл", text: $email)
                                .keyboardType(.emailAddress)
                                .textContentType(.username)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                                .focused($focus, equals: .email)
                                .onChange(of: email) { _, new in email = ascii(new) }
                                .padding(.horizontal, 12)
                                .frame(height: 48)
                                .background(Color.fieldBG)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(focus == .email ? Color.brand : Color(.systemGray3),
                                                lineWidth: focus == .email ? 2 : 1)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .submitLabel(.next)
                                .onSubmit { focus = .password }

                            // Password
                            SecureField("Нууц үг", text: $password)
                                .textContentType(.password)
                                .focused($focus, equals: .password)
                                .onChange(of: password) { _, new in password = ascii(new) }
                                .padding(.horizontal, 12)
                                .frame(height: 48)
                                .background(Color.fieldBG)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(focus == .password ? Color.brand : Color(.systemGray3),
                                                lineWidth: focus == .password ? 2 : 1)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .submitLabel(.go)
                                .onSubmit { if isLoginEnabled { login() } }

                            if let error = authVM.error, !error.isEmpty {
                                Text(error)
                                    .foregroundColor(.red)
                                    .font(.footnote)
                            }

                            Button { login() } label: {
                                Text("Нэвтрэх").font(.system(size: 16, weight: .semibold))
                            }
                            .buttonStyle(PrimaryButtonStyle())
                            .disabled(!isLoginEnabled || authVM.isLoading)

                            Button("Нууц үгээ мартсан уу?") {
                                Task {
                                    await authVM.resetPassword(email: email)
                                    resetMessage = "Хэрэв бүртгэл байгаа бол сэргээх имэйл илгээгдсэн."
                                    showResetAlert = true
                                }
                            }
                            .font(.footnote)
                            .frame(maxWidth: .infinity, alignment: .leading)

                            Divider().padding(.vertical, 4)

                            Button {
                                authVM.error = nil
                                showRegister = true
                                Haptics.tap()
                            } label: {
                                Text("Бүртгэл үүсгэх")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .buttonStyle(SecondaryButtonStyle())
                        }
                    }

                    if authVM.isLoading { ProgressView() }
                    Spacer(minLength: 16)
                }
                .padding(.bottom, 12)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .fullScreenCover(isPresented: $showRegister) {
            RegisterView().environmentObject(authVM)
        }
        .alert(resetMessage, isPresented: $showResetAlert) {
            Button("ОК", role: .cancel) {}
        }
        .onAppear { focus = .email }
    }

    /// Attempts to authenticate the user with the current credentials.
    /// Leading and trailing spaces are removed before sending to the view model
    /// to prevent login failures from accidental whitespace.
    private func login() {
        authVM.error = nil
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        Haptics.tap()
        print("Login tapped")
        Task { await authVM.login(email: trimmedEmail, password: trimmedPassword) }
    }
}
