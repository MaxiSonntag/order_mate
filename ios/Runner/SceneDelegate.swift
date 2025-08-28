//
//  ScreenDelegate.swift
//  Runner
//
//  Created by Maximilian Sonntag on 02.08.24.
//

import Foundation

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var openPath: String?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {

        guard let windowScene = scene as? UIWindowScene else { return }

        window = UIWindow(windowScene: windowScene)
        let flutterEngine = FlutterEngine(name: "SceneDelegateEngine")
        flutterEngine.run()
        GeneratedPluginRegistrant.register(with: flutterEngine)
        let controller = FlutterViewController.init(
            engine: flutterEngine,
            nibName: nil,
            bundle: nil
        )

        window?.rootViewController = controller
        window?.makeKeyAndVisible()

        if let vc = window?.rootViewController as? FlutterViewController {
            FileOpenRouter.shared.attach(to: vc)
        } else {
            DispatchQueue.main.async {
                if let vc = self.window?.rootViewController
                    as? FlutterViewController
                {
                    FileOpenRouter.shared.attach(to: vc)
                }
            }
        }

        // Launch via URL into this scene
        if let url = connectionOptions.urlContexts.first?.url {
            print("SceneDelegate launch URL: \(url.path)")
            FileOpenRouter.shared.handle(url: url)
        }
    }

    func scene(
        _ scene: UIScene,
        openURLContexts URLContexts: Set<UIOpenURLContext>
    ) {
        guard let url = URLContexts.first?.url else { return }
        print("SceneDelegate open URL: \(url.path)")
        FileOpenRouter.shared.handle(url: url)
    }
}
