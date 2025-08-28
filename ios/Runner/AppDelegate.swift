import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication
            .LaunchOptionsKey: Any]?
    ) -> Bool {
        let ok = super.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )

        // Attach channel once FlutterViewController exists (retry shortly if needed)
        func attachSoon() {
            if let vc = self.window?.rootViewController
                as? FlutterViewController
            {
                FileOpenRouter.shared.attach(to: vc)
            } else {
                DispatchQueue.main.asyncAfter(
                    deadline: .now() + 0.05,
                    execute: attachSoon
                )
            }
        }
        DispatchQueue.main.async(execute: attachSoon)

        // If launched by tapping a file
        FileOpenRouter.shared.handle(launchURL: launchOptions?[.url] as? URL)
        return ok
    }

    override func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        print("AppDelegate open URL: \(url.path)")
        FileOpenRouter.shared.handle(url: url)
        return true
    }
}
