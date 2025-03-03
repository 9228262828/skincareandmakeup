//
//  FLTPerfectLibHandler.swift
//  Runner
//
//  Created by i lin on 2024/2/7.
//

import Flutter
import PerfectLibCore

class FLTPerfectLibMethodHandler: NSObject {
    private let previewMode:String = "previewMode"
    private let mappingMode:String = "mappingMode"
    private let developerMode:String = "developerMode"
    private let imageSource:String = "imageSource"
    private let configFile:String = "configFile"
    private let modelFolder:String = "modelFolder"
    private let userId:String = "userId"
    
    static let shared = FLTPerfectLibMethodHandler()
    
    private var methodChannel: FlutterMethodChannel?
    
    private override init() {
        super.init()
    }
    
    func initialize(channelName: String, binaryMessenger: FlutterBinaryMessenger) {
        methodChannel = FlutterMethodChannel(name: channelName, binaryMessenger: binaryMessenger)
        methodChannel?.setMethodCallHandler(handle(_:result:))
    }

    func invokeMethod(_ methodName: String, arguments: Any?) {
        methodChannel?.invokeMethod(methodName, arguments: arguments)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any] else {
            return result(nil)
        }
        
        switch call.method {
        case "init":
            let builder = PerfectLibConfigurationBuilder()
            if let imageSource = arguments[imageSource] as? Int {
                builder.setImageSource(ImageSource(rawValue: UInt(imageSource))!)
            }
            if let previewMode = arguments[previewMode] as? Bool {
                builder.setPreviewMode(previewMode)
            }
            if let mappingMode = arguments[mappingMode] as? Bool {
                builder.setMappingMode(mappingMode)
            }
            if let developerMode = arguments[developerMode] as? Bool {
                builder.setDeveloperMode(developerMode)
            }
            if let userId = arguments[userId] as? String, userId != "" {
                builder.setUserId(userId)
            } else {
                builder.setUserId(UUID().uuidString)
            }
    // Handle the config file path logic
           if let configFile = arguments[configFile] as? String, configFile != "" {
               // iOS specific code
               if #available(iOS 9.0, *) {
                   if let configPath = Bundle.main.path(forResource: "config", ofType: "json") {
                       log("[PerfectLibHandler] Set configFile Path from Bundle: \(configPath)")
                       builder.setConfigFile(configPath)
                       print("Path to config.json from Bundle: \(configPath)")
                   } else {
                       print("config.json not found in the app bundle!")
                   }
               } else {
                   // Fallback to Documents directory
                   if let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first as NSString? {
                       log("[PerfectLibHandler] Set configFile Path from Documents: \(configFile)")
                       let configFilePath = docPath.appendingPathComponent(configFile)
                       builder.setConfigFile(configFilePath)
                       print("Path to config.json from Documents: \(configFilePath)")
                   }
               }
           } else {
               // Default to app bundle if no config file is passed
               if let configPath = Bundle.main.path(forResource: "config", ofType: "json") {
                   builder.setConfigFile(configPath)
                   print("Path to config.json from Bundle: \(configPath)")
               } else {
                   print("config.json not found in the app bundle!")
               }
           }


          if let modelFolder = arguments[modelFolder] as? String, modelFolder != "" {
                      if let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first as NSString? {
                          log("[PerfectLibHandler] Set modelFolder Path: \(modelFolder)")
                          let modelFolderPath = docPath.appendingPathComponent(modelFolder)
                          builder.setModelsPath(modelFolderPath)
                      }
                  } else {
                      if let modelPath = Bundle.main.path(forResource: "model", ofType: "") {
                          builder.setModelsPath(modelPath)
                      }
                  }
            
            PerfectLib.initWith(builder.build()) { _, _ in
                return result (true)
            } failureBlock: { error in
                FLTPerfectLibMethodHandler.shared.invokeMethod("error", arguments: error?.localizedDescription)
            }
        case "setCountryCode":
            guard let code = arguments["countryCode"] as? String else { return result(nil) }
            log("[PerfectLibHandler] Set Country Code: \(code)")
            PerfectLib.setCountryCode(code)
            return result(nil)
        case "setLocaleCode":
            guard let code = arguments["localeCode"] as? String else { return result(nil) }
            log("[PerfectLibHandler] Set Locale Code: \(code)")
            PerfectLib.setLocaleCode(code)
            return result(nil)
        case "getCountryCode":
            log("[PerfectLibHandler] Get Country Code")
            return result(PerfectLib.getCountryCode())
        case "getLocaleCode":
            log("[PerfectLibHandler] Get Locale Code")
            return result(PerfectLib.getLocaleCode())
        case "unload":
            PerfectLib.uninit()
            log("[PerfectLibHandler] Uninit")
            return result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
