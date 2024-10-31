import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        if let registrar = self.registrar(forPlugin: "skincarePlugin"),
           let controller = window?.rootViewController as? FlutterViewController {
            FLTSkinCarePlugin.register(with: registrar)
            
            // PerfectLib
            FLTPerfectLibMethodHandler.shared.initialize(channelName: "PerfectLibMethodChannel", binaryMessenger: controller.binaryMessenger)
            
        }
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}


