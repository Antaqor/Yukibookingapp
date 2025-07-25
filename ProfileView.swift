import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var authVM: AuthViewModel

    var body: some View {
        VStack(spacing: 16) {
            if let email = authVM.user?.email {
                Text(email)
                    .font(.headline)
            }
            Button("Sign Out") {
                authVM.signOut()
            }
            .padding()
            Spacer()
        }
        .navigationTitle("Profile")
    }
}

#if DEBUG
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView().environmentObject(AuthViewModel())
    }
}
#endif
