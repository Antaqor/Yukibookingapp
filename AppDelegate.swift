import UIKit
import FirebaseCore
import FirebaseDatabase

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()

        // Realtime DB кэш working — query оффлайн/онлайн гацахгүй байхад тусална
        Database.database().isPersistenceEnabled = true

        // Зарим орчинд SDK offline үлддэг — шууд онлайн болгоё
        Database.database().goOnline()

        // App идэвхжих бүрт дахин онлайн болгоно (network state тогтворгүй үед хэрэгтэй)
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            Database.database().goOnline()
        }

        return true
    }
}
