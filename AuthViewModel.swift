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

    func login(email: String, password: String) async {
        isLoading = true
        error = nil
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.user = result.user
            await fetchUserRole()
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func register(email: String, password: String) async {
        isLoading = true
        error = nil
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.user = result.user
            let ref = Database.database().reference().child("users").child(result.user.uid)
            try await ref.setValue(["role": "user"])
            await fetchUserRole()
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.user = nil
            self.role = nil
        } catch {
            self.error = error.localizedDescription
        }
    }
}
