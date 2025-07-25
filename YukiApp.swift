import SwiftUI

@main
struct YukiAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authVM = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            Group {
                if authVM.user == nil {
                    EmailAuthView().environmentObject(authVM)
                } else if authVM.role == "artist" {
                    DashboardView().environmentObject(authVM)
                } else if authVM.role == "user" {
                    LocationSelectionView().environmentObject(authVM)
                } else {
                    ProgressView()
                }
            }
        }
    }
}
