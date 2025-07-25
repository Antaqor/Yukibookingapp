import SwiftUI

/// Tab bar displayed for admin users.
struct AdminTabView: View {
    var body: some View {
        TabView {
            NavigationView {
                DashboardView()
            }
            .tabItem {
                Image(systemName: "house")
                Text("Home")
            }

            NavigationView {
                ArtistManagementView()
            }
            .tabItem {
                Image(systemName: "person.3")
                Text("Artists")
            }

            NavigationView {
                FinanceView()
            }
            .tabItem {
                Image(systemName: "creditcard")
                Text("Finance")
            }
        }
    }
}
