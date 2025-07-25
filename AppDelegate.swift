import UIKit
import FirebaseCore
import FirebaseDatabase

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        // Enable offline persistence so queries can be served from cache when
        // the device is offline. This helps avoid "client offline" errors when
        // there are no active listeners.
        Database.database().isPersistenceEnabled = true
        return true
    }
}
