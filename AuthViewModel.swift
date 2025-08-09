import Foundation
import FirebaseAuth
import FirebaseDatabase

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var role: String?
    @Published var error: String?
    @Published var isLoading = false

    init() {
        user = Auth.auth().currentUser
        Task { await fetchUserRole() }
    }

    /// Maps Firebase errors to user friendly messages
    private func handleAuthError(_ error: Error) {
        // Convert ``NSError`` code into Firebase's ``AuthErrorCode`` enumeration
        if let code = AuthErrorCode(rawValue: (error as NSError).code) {
            switch code {
            case .invalidEmail:
                self.error = "Имэйл хаяг буруу"
            case .emailAlreadyInUse:
                self.error = "Имэйл аль хэдийн ашиглагдсан"
            case .weakPassword:
                self.error = "Нууц үг хэт сул байна"
            case .wrongPassword, .userNotFound:
                self.error = "Имэйл эсвэл нууц үг буруу"
            case .userDisabled:
                self.error = "Энэ аккаунт идэвхгүй болсон"
            case .invalidCredential, .invalidUserToken, .userTokenExpired:
                self.error = "Нэвтрэх мэдээллийн хугацаа дууссан. Дахин нэвтэрнэ үү"
            case .networkError:
                self.error = "Сүлжээний алдаа. Холболтоо шалгана уу"
            case .tooManyRequests:
                self.error = "Хэт олон оролдлого. Дараа дахин оролдоно уу"
            default:
                self.error = error.localizedDescription
            }
        } else {
            self.error = error.localizedDescription
        }
    }

    func fetchUserRole() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("users").child(uid).child("role")
        do {
            let snapshot = try await ref.getData()
            self.role = snapshot.value as? String ?? "user"
        } catch {
            self.role = "user"
        }
    }

    /// Performs user login with basic validation
    func login(email: String, password: String) async {
        guard !email.isEmpty, !password.isEmpty else {
            self.error = "Имэйл болон нууц үг шаардлагатай"
            return
        }
        isLoading = true
        print("Login started for \(email)")
        error = nil
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.user = result.user
            await fetchUserRole()
            print("Login succeeded for user: \(result.user.uid)")
        } catch {
            handleAuthError(error)
            print("Login failed: \(error.localizedDescription)")
        }
        isLoading = false
        print("Login finished")
    }

    /// Registers a new user in Firebase with validation
    func register(name: String, phone: String, email: String, password: String, confirmPassword: String) async {
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty else {
            self.error = "Бүх талбар заавал бөглөнө"
            return
        }
        guard password == confirmPassword else {
            self.error = "Нууц үг таарахгүй байна"
            return
        }
        guard password.count >= 6 else {
            self.error = "Нууц үг дор хаяж 6 тэмдэгт байх ёстой"
            return
        }
        isLoading = true
        error = nil
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.user = result.user
            let ref = Database.database().reference().child("users").child(result.user.uid)
            try await ref.setValue(["role": "user", "name": name, "phone": phone, "email": email])
            await fetchUserRole()
        } catch {
            handleAuthError(error)
        }
        isLoading = false
    }

    func resetPassword(email: String) async {
        guard !email.isEmpty else {
            self.error = "Имэйл хаягаа оруулна уу"
            return
        }
        isLoading = true
        error = nil
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
            handleAuthError(error)
        }
        isLoading = false
    }

    /// Signs out the current user and clears local state.
    func signOut() {
        do {
            try Auth.auth().signOut()
            // Reset published properties so views update correctly
            self.user = nil
            self.role = nil
            self.error = nil
        } catch {
            handleAuthError(error)
        }
    }
}
