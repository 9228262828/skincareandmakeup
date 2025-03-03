import UIKit
import Flutter
import FBSDKCoreKit

@main
@objc class AppDelegate: FlutterAppDelegate {

    // Override to handle application launch
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Facebook SDK initialization
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)

        // Register Flutter plugins
        GeneratedPluginRegistrant.register(with: self)

        // Register custom Flutter plugins
        if let registrar = self.registrar(forPlugin: "skincarePlugin"),
           let controller = window?.rootViewController as? FlutterViewController {
            FLTSkinCarePlugin.register(with: registrar)

            // Initialize PerfectLib
            FLTPerfectLibMethodHandler.shared.initialize(channelName: "PerfectLibMethodChannel", binaryMessenger: controller.binaryMessenger)
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    override func application(
        _ application: UIApplication,
        open url: URL,
        sourceApplication: String?,
        annotation: Any
    ) -> Bool {
        return ApplicationDelegate.shared.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }

}
