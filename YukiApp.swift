import SwiftUI

/// Entry point of the application.
/// Injects AuthViewModel once at the root.
@main
struct YukiApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject private var authVM = AuthViewModel()
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore = false

    var body: some Scene {
        WindowGroup {
            Group {
                switch (authVM.user, authVM.role) {
                case (nil, _):
                    // First time -> Register, дараагийн удаа -> Login (гараар сольж болно)
                    if hasLaunchedBefore {
                        LoginView()
                    } else {
                        RegisterView()
                    }

                case (_, "admin"):
                    AdminTabView()

                case (_, "artist"):
                    ArtistTabView()

                case (_, "user"):
                    MainTabView()

                default:
                    ProgressView()
                }
            }
            .tint(Color("AccentColor"))
            .environmentObject(authVM)
        }
    }
}
