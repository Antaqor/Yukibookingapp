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
                Text("Нүүр")
            }

            NavigationView {
                ArtistManagementView()
            }
            .tabItem {
                Image(systemName: "person.3")
                Text("Артистууд")
            }

            NavigationView {
                FinanceView()
            }
            .tabItem {
                Image(systemName: "creditcard")
                Text("Санхүү")
            }
        }
    }
}
