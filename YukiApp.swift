import SwiftUI

/// Entry point of the application.
/// Uses the MVVM architecture by injecting the ``AuthViewModel``
/// into the environment for all child views.

@main
struct YukiAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authVM = AuthViewModel()
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore = false

    var body: some Scene {
        WindowGroup {
            Group {
                if authVM.user == nil {
                    if hasLaunchedBefore {
                        LoginView().environmentObject(authVM)
                    } else {
                        RegisterView().environmentObject(authVM)
                    }
                } else if authVM.role == "admin" {
                    DashboardView().environmentObject(authVM)
                } else if authVM.role == "user" {
                    MainTabView().environmentObject(authVM)
                } else {
                    ProgressView()
                }
            }
            .tint(Color("AccentColor"))
        }
    }
}
