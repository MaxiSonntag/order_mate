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
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = scene as? UIWindowScene else { return }
        
        window = UIWindow(windowScene: windowScene)
        let flutterEngine = FlutterEngine(name: "SceneDelegateEngine")
        flutterEngine.run()
        GeneratedPluginRegistrant.register(with: flutterEngine)
        let controller = FlutterViewController.init(engine: flutterEngine, nibName: nil, bundle: nil)
        
        let channel = FlutterMethodChannel(name: "OPEN_OM_FILE", binaryMessenger: controller.binaryMessenger)
        
        channel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            guard call.method == "getOpenFileUrl" else {
                result(FlutterMethodNotImplemented)
                return
            }
            
            self?.getOpenFileUrl(result: result)
        })
        
        window?.rootViewController = controller
        window?.makeKeyAndVisible()
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        for urlContext in URLContexts {
            let url = urlContext.url
            openPath = url.absoluteString
            print("Handle URL: (url)")
        }
    }
    
    private func getOpenFileUrl(result: @escaping FlutterResult) {
        if let openPath {
            result(openPath)
            self.openPath = nil
        } else {
            result(FlutterError.init(code: "NO_PATH",
                                     message: "No file path to open",                                    details: nil
                                    )
            )
        }
    }
}
