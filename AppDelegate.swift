import Firebase
import GoogleSignIn
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // Проверяем наличие GoogleService-Info.plist перед инициализацией Firebase
        guard Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil else {
            print("⚠️ GoogleService-Info.plist не найден, но продолжаем для демо")
            return true
        }

        // Настраиваем Firebase
        FirebaseApp.configure()

        return true
    }

    func application(
        _ app: UIApplication, open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}
