import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
 GMSServices.provideAPIKey("AIzaSyAJr2jWZ_YLhxb-wpzxb43HoX92qfCP6jA")
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
}
