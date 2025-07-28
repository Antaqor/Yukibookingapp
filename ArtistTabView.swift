import SwiftUI

/// Tab bar displayed for artist accounts.
/// Shows bookings and personal profile.
struct ArtistTabView: View {
    @StateObject private var router = TabRouter()

    var body: some View {
        TabView(selection: $router.selection) {
            NavigationView {
                ArtistDashboardView()
            }
            .tabItem {
                Image(systemName: "house")
                Text("Нүүр")
            }
            .tag(0)

            NavigationView {
                ProfileView()
            }
            .tabItem {
                Image(systemName: "person")
                Text("Профайл")
            }
            .tag(1)
        }
        .environmentObject(router)
    }
}

#if DEBUG
struct ArtistTabView_Previews: PreviewProvider {
    static var previews: some View {
        ArtistTabView().environmentObject(AuthViewModel())
    }
}
#endif
