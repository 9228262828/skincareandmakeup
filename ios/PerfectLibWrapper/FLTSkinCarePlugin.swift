//
//  PerfectSDKSkinCareBridgeHandler.swift
//  Runner
//
//  Created by i lin on 2024/1/29.
//

import Foundation
import Flutter
import UIKit
import AVFoundation

public class FLTSkinCarePlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let factory = FLSkincareCamViewFactory(messenger: registrar.messenger())
        registrar.register(factory, withId: "skincare_view")
    }
}
