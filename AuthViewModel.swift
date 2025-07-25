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
                self.error = "Invalid email address"
            case .emailAlreadyInUse:
                self.error = "Email already in use"
            case .weakPassword:
                self.error = "Password is too weak"
            case .wrongPassword, .userNotFound:
                self.error = "Incorrect email or password"
            case .userDisabled:
                self.error = "This account has been disabled"
            case .invalidCredential, .invalidUserToken, .userTokenExpired:
                self.error = "The supplied credentials have expired. Please log in again"
            case .networkError:
                self.error = "Network error. Please check your connection"
            case .tooManyRequests:
                self.error = "Too many attempts. Please try again later"
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
            self.error = "Email and password are required"
            return
        }
        isLoading = true
        error = nil
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.user = result.user
            await fetchUserRole()
        } catch {
            handleAuthError(error)
        }
        isLoading = false
    }

    /// Registers a new user in Firebase with validation
    func register(name: String, phone: String, email: String, password: String, confirmPassword: String) async {
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty else {
            self.error = "All fields are required"
            return
        }
        guard password == confirmPassword else {
            self.error = "Passwords do not match"
            return
        }
        guard password.count >= 6 else {
            self.error = "Password must be at least 6 characters"
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
            self.error = "Please enter your email"
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
