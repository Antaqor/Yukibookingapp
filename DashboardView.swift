import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var authVM: AuthViewModel

    var body: some View {
        VStack {
            Text("Artist Dashboard")
                .font(.title)
            Button("Sign Out") {
                authVM.signOut()
            }
            .padding()
        }
    }
}
