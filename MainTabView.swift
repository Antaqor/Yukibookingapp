import SwiftUI

/// Main tab bar shown to regular users.
/// Uses ``TabRouter`` so child views can programmatically switch tabs.
struct MainTabView: View {
    @StateObject private var router = TabRouter()

    var body: some View {
        TabView(selection: $router.selection) {
            NavigationView {
                LocationSelectionView()
            }
            .tabItem {
                Image(systemName: "house")
                Text("Home")
            }
            .tag(0)

            NavigationView {
                ProfileView()
            }
            .tabItem {
                Image(systemName: "person")
                Text("Profile")
            }
            .tag(1)
        }
        // Provide router to all tab child views
        .environmentObject(router)
    }
}

#if DEBUG
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView().environmentObject(AuthViewModel())
    }
}
#endif
