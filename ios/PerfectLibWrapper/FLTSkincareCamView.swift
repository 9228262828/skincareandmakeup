//
//  FLNativeView.swift
//  Runner
//
//  Created by i lin on 2024/1/30.
//

import Flutter
import UIKit
import PerfectLibCore
import PerfectLibSkinCarePlus
import os

// MARK: - extensions for PerfectLib enumeratios
extension PFFaceAreaQuality {
    var string: String {
        switch self {
        case .tooSmall: return "TooSmall"
        case .outOfBoundary: return "OutOfBoundary"
        case .unknown: return "Unknown"
        case .good: return "Good"
        default:
            return "Unknown"
        }
    }
}

extension PFLightingQuality2 {
    var string: String {
        switch self {
        case .backlighting: return "Backlighting"
        case .uneven: return "Uneven"
        case .overExposed: return "OverExposed"
        case .underExposed: return "UnderExposed"
        case .unknown: return "Unknown"
        case .normal: return "Normal"
        case .good: return "Good"
        default:
            return "Unknown"
        }
    }
}

extension PFFaceFrontalQuality {
    var string: String {
        switch self {
        case .unknown: return "Unknown"
        case .bad: return "Bad"
        case .good: return "Good"
        default:
            return "Unknown"
        }
    }
}

extension PFSkinType {
    var string: String {
        switch self {
        case .unknown:
            return "Unknown"
        case .normal:
            return "Normal"
        case .dry:
            return "Dry"
        case .oily:
            return "Oily"
        case .combination:
            return "Combination"
        case .normalAndSensitive:
            return "Normal and Sensitive"
        case .dryAndSensitive:
            return "Dry and Sensitive"
        case .oilyAndSensitive:
            return "Oily and Sensitive"
        case .combinationAndSensitive:
            return "Combination and Sensitive"
        default:
            return ""
        }
    }
}

class FLSkincareCamViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return FlutterSkinCareView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger)
    }

    /// Implementing this method is only necessary when the `arguments` in `createWithFrame` is not `nil`.
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
          return FlutterStandardMessageCodec.sharedInstance()
    }
}

class FlutterSkinCareView: NSObject, FlutterPlatformView {
    private var _view: FLTSkincareCamView

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        _view = FLTSkincareCamView()
        // Skincare
        let channel = FlutterMethodChannel(name: "PerfectSDKSkinCareView/\(viewId)", binaryMessenger: messenger!)
        _view.channel = channel
        if let arguments = args as? [String: Any],
           let width = arguments["width"] as? CGFloat,
           let height = arguments["height"] as? CGFloat {
            _view.frame = CGRect(x: 0, y: 0, width: width, height: height)
        }
        _view.backgroundColor = UIColor.white
        super.init()
        channel.setMethodCallHandler(self.handle(_:result:))
        // iOS views can be created here
    }

    func view() -> UIView {
        return _view
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Check the view id
        guard let arguments = call.arguments as? [String: Any] else {
            return result(nil)
        }
        
        switch call.method {
        case "takePicture":
            log("[SkinCareHandler] Take Picture")
            _view.takePicture()
            return result(nil)
        case "start":
            log("[SkinCareHandler] Session Start")
            _view.start()
            return result(nil)
        case "stop":
            log("[SkinCareHandler] Session Stop")
            _view.stop()
            return result(nil)
        case "pause":
            log("[SkinCareHandler] Session Pause")
            _view.pause()
            return result(nil)
        case "resume":
            log("[SkinCareHandler] Session Resume")
            _view.resume()
            return result(nil)
        case "getAvailableFeatures":
            log("[SkinCareHandler] getAvailableFeatures")
            let features = _view.getAvailableFeatures()
            return result(features)
        case "analyzeImage":
            log("[SkinCareHandler] analyzeImage")
            guard let image = arguments["image"] as? String else { return result(false) }
            _view.setImage(image) { isSuccess in
                return result(isSuccess)
            }
        case "getOverallScore":
            log("[SkinCareHandler] getOverallScore")
            _view.getOverallScore { scores in
                return result(scores)
            }
        case "getReports":
            log("[SkinCareHandler] getReports")
            _view.getReports { reports in
                return result(reports)
            }
        case "getSkinTypes":
            log("[SkinCareHandler] getSkinTypes")
            _view.getSkinTypes { skinTypes in
                return result(skinTypes)
            }
        case "getAnalyzedImage":
            log("[SkinCareHandler] getAnalyzedImage")
            guard let features = arguments["features"] as? [String] else {
                return result(nil)
            }
            _view.getAnalyzedImage(features) { image in
                if let image = image {
                    if let imageData = image.pngData() {
                        // Send the base64 image data back to Flutter
                        result(imageData.base64EncodedString())
                    }
                }
                result(FlutterError(code: "ANALYZE_FAILED", message: "Analyze failed", details: nil))
            }
        case "getSkinTypeAnalyzedImage":
            log("[SkinCareHandler] getSkinTypeAnalyzedImage")
            _view.getSkinTypeAnalyzedImage { image in
                if let image = image {
                    if let imageData = image.pngData() {
                        // Send the base64 image data back to Flutter
                        result(imageData.base64EncodedString())
                    }
                }
                result(FlutterError(code: "ANALYZE_FAILED", message: "Analyze failed", details: nil))
            }
        case "dispose":
            _view.unload()
            return result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

func log(_ message: String) {
    if #available(iOS 14, *) {
        let logger = Logger(subsystem: "skincare_flutter", category: "APP")
        logger.log("\(message, privacy: .public)")
    }
    else {
        
    }
}

class FLTSkincareCamView: UIView {
    private var skincare: SkinCare?
    private var session: AVCaptureSession?
    private var input: AVCaptureDeviceInput?
    private var photoOutput: AVCapturePhotoOutput?
    private var paused: Bool = true
    
    private var skinAge: Int?
    private var overallScore: Int?
    private var lastAnalysisSkincareData: [PFSkinAnalysisData]?
    private var lastSkinTypeAnalysisData: [PFSkinTypeAnalysisData]?
    private var onCheckResult: [String:String] = [:]
    
    var currentPreset: AVCaptureSession.Preset? {
        didSet {
            guard let preset = self.currentPreset else { return }
            SynchronousTool.asyncMainSafe { [weak self] in
                guard let self = self else { return }
                var frame : CGRect
                if preset == .photo {
                    frame = self.getFrameBy(aspectRatio: 4.0/3.0)
                }
                else {
                    frame = self.getFrameBy(aspectRatio: 16.0/9.0)
                }
                self.bounds = frame
            }
        }
    }
    
    var channel: FlutterMethodChannel?

    
    // Set the camera position
    private var cameraPos:AVCaptureDevice.Position = .front
    
    deinit {
        channel = nil
        skincare = nil
        session = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard self.skincare == nil else { return }
        if currentPreset == nil {
            currentPreset = AVCaptureSession.Preset.photo
        }
        log("[SkincareCamView] Creating SkinCare...")
        SkinCare.create() { [weak self] (skincare, error) in
            guard let self = self else { return }
            self.skincare = skincare
            self.skincare?.delegate = self
            self.setupCameraAndPreview()
            self.skincare?.onCameraOpen(true)
            log("[SkincareCamView] Create SkinCare Success")
        }
    }
    
    func takePicture() {
        guard let photoOutput = photoOutput else { return }
        let setting = AVCapturePhotoSettings()
        setting.flashMode = .off
        photoOutput.capturePhoto(with: setting, delegate: self)
    }
    
    func start() {
        guard let session = session else { return }
        DispatchQueue.global(qos: .background).async { [self] in
            session.startRunning()
            paused = false
        }
    }
    
    func stop() {
        guard let session = session else { return }
        DispatchQueue.global(qos: .background).async { [self] in
            session.stopRunning()
            paused = true
        }
    }
    
    func pause() {
        paused = true
    }
    
    func resume() {
        paused = false
    }
    
    func setImage(_ base64String: String, completion: @escaping (Bool) -> Void) {
        guard let skincare = skincare else { return }
        let dataDecoded : Data = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters)!
        if let image = UIImage(data: dataDecoded) {
            skincare.setImage(image) { error in
                if error != nil {
                    self.errorMessage(error!.localizedDescription)
                }
                return error == nil ? completion(true) : completion(false)
            }
        }
        return;
    }
    
    func getAvailableFeatures() -> [String] {
        guard let skincare = skincare else { return [] }
        return skincare.availableFeatures
    }
    
    func getOverallScore(completion: @escaping ([String:String]) -> Void) {
        guard let skincare = skincare else { return }
        skincare.getOverallScore { overallScore, skinAge  in
            var result:[String:String] = [:]
            self.overallScore = Int(overallScore)
            self.skinAge = Int(skinAge)
            result["overallScore"] = String(self.overallScore!)
            result["skinAge"] = String(self.skinAge!)
            log("[SkincareCamView] OverallScore: \(overallScore), SkinAge: \(skinAge)")
            completion(result)
        }
    }
    
    func getReports(completion: @escaping ([String:String]) -> Void) {
        guard let skincare = skincare else { return }
        skincare.getReports(bySkinFeatures: skincare.availableFeatures) { reports in
            var result:Dictionary<String, String> = [:]
            self.lastAnalysisSkincareData = reports
            reports.forEach {
                result[$0.feature] = String($0.score)
            }
            log("[SkincareCamView] reports:")
            dump(result)
            completion(result)
        }
    }
    
    func getSkinTypes(completion: @escaping ([String:String]) -> Void) {
        guard let skincare = skincare else { return }
        skincare.getSkinTypes { reports in
            var result:Dictionary<String, String> = [:]
            self.lastSkinTypeAnalysisData = reports
            reports.forEach {
                result[$0.feature] = String($0.skinType.string)
            }
            log("[SkincareCamView] SkinTypes:")
            dump(result)
            completion(result)
        }
    }
    
    func getAnalyzedImage(_ features: [String], completion: @escaping (UIImage?) -> Void) {
        guard let skincare = skincare else { return }
        skincare.getAnalyzedImage(bySkinFeatures: features) { image, error in
            if let error = error {
                log("[SkincareCamView] getAnalyzedImage failed : \(error.localizedDescription)")
            }
            completion(image)
        }
    }
    
    func getSkinTypeAnalyzedImage(completion: @escaping (UIImage?) -> Void) {
        guard let skincare = skincare else { return }
        skincare.getSkinTypeAnalyzedImage { image, error in
            if let error = error {
                log("[SkincareCamView] getSkinTypeAnalyzedImage failed : \(error.localizedDescription)")
            }
            completion(image)
        }
    }
    
    func unload() {
        stop()
        channel = nil
    }
    
    func errorMessage(_ error:String) {
        if let channel = self.channel {
            SynchronousTool.asyncMainSafe {
                log("[SkincareCamView] \(error)")
                channel.invokeMethod("error", arguments:error)
            }
        }
    }
    
    private func getFrameBy(aspectRatio ratio:CGFloat) -> CGRect {
        let screenW = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        let screenH = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        var w = screenW
        var h = w * ratio
        
        if h > screenH {
            h = screenH
            w = h / ratio
        }
        
        return CGRect(x: 0, y: 0, width: w, height: h)
    }

}

extension FLTSkincareCamView: SkinCareDelegate {
    func skinCare(_ skinCare: SkinCare, checkedResult: PFSkinCareQualityCheck) {
        if paused == true {
            return
        }
        self.onCheckResult["faceLighting"] = checkedResult.lightingQuality.string
        self.onCheckResult["faceArea"] = checkedResult.faceAreaQuality.string
        self.onCheckResult["faceFront"] = checkedResult.faceFrontalQuality.string
        
        if let channel = self.channel {
            SynchronousTool.asyncMainSafe { [weak self] in
                log("[SkincareCamView] faceLighting: \(checkedResult.lightingQuality.string), faceArea: \(checkedResult.faceAreaQuality.string), faceFront: \(checkedResult.faceFrontalQuality.string)")
                channel.invokeMethod("onCheckResult", arguments: self?.onCheckResult)
            }
        }
    }
}

extension FLTSkincareCamView: AVCaptureVideoDataOutputSampleBufferDelegate {
    func requestCameraAuthentication(_ completion: @escaping (_ authorized: Bool)->Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video) { authorized in
                completion(authorized)
            }
        }
        else {
            completion(status == .authorized)
        }
    }
    
    func setupCameraAndPreview() {
        requestCameraAuthentication { [weak self] authorized in
            guard let self = self else { return }
            if authorized {
                SynchronousTool.asyncMainSafe { [ weak self] in
                    guard let self = self else { return }
                    self._setupCameraAndPreview()
                }
            }
            else {
                // Access denied
                self.errorMessage("Authorize camera failed. Please allow access in the setting page.")
                return
            }
        }
    }
    
    func _setupCameraAndPreview() {
        log("opening camera")
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: cameraPos) else { fatalError() }
        let session = AVCaptureSession()
        
        session.beginConfiguration()
        guard let input = try? AVCaptureDeviceInput(device: device) else { fatalError() }
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        let output = AVCaptureVideoDataOutput()
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]
        output.alwaysDiscardsLateVideoFrames = false
        
        let queue = DispatchQueue(label: "com.perfectlib.processsamplebuffer")
        output.setSampleBufferDelegate(self, queue: queue)
        
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        
        let photoOutput = AVCapturePhotoOutput()
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)

            self.photoOutput = photoOutput
            photoOutput.isHighResolutionCaptureEnabled = true
            
            let deviceOrientation = UIDevice.current.orientation
            if let photoOutputConnection = photoOutput.connection(with: .video), let newVideoOrientation = AVCaptureVideoOrientation(rawValue: deviceOrientation.rawValue) {
                    // Fix flutter debug mode the orientation is not working.
                    photoOutputConnection.videoOrientation = deviceOrientation == .unknown ? .portrait : newVideoOrientation
            }
        }
        
        session.sessionPreset = currentPreset!
        session.commitConfiguration()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = CGRect(origin: CGPoint.zero, size: self.frame.size)
        previewLayer.videoGravity = .resizeAspectFill
        self.layer.addSublayer(previewLayer)
        
        DispatchQueue.global(qos: .background).async {
            session.startRunning()
            self.paused = false
        }
        
        self.session = session
        self.input = input
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let skincare = skincare else { return }
        skincare.sendCameraBuffer(sampleBuffer)
    }
}

extension FLTSkincareCamView: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        if let previewImage = UIImage(data: imageData) {
            var rotatedImage : UIImage
            switch currentDeviceOrientation() {
            case .portrait:
                rotatedImage = UIImage(cgImage: (previewImage.rotate(radians: .pi * 2))!.cgImage!, scale: 1.0, orientation: .up)
            case .landscapeLeft:
                rotatedImage = UIImage(cgImage: (previewImage.rotate(radians: -.pi * 1.5))!.cgImage!, scale: 1.0, orientation: .up)
            case .landscapeRight:
                rotatedImage = UIImage(cgImage: previewImage.cgImage!, scale: 1.0, orientation: .up)
            default:
                rotatedImage = UIImage(cgImage: (previewImage.rotate(radians: .pi * 2))!.cgImage!, scale: 1.0, orientation: .up)
            }
            if cameraPos == .front {
                rotatedImage = rotatedImage.flipImage()!
            }
            if let imageData = rotatedImage.pngData() {
                // Send the base64 image data back to Flutter
                if let channel = self.channel {
                    SynchronousTool.asyncMainSafe {
                        channel.invokeMethod("image", arguments: imageData.base64EncodedString())
                    }
                }
            }
            
        }
    }
    
    private func currentDeviceOrientation() -> UIDeviceOrientation {
        guard (UIDevice.current.orientation != .portrait && UIDevice.current.orientation != .portraitUpsideDown &&
               UIDevice.current.orientation != .landscapeRight && UIDevice.current.orientation != .landscapeLeft) else {
            return UIDevice.current.orientation
        }
        
        var orientation : UIInterfaceOrientation?
        if #available(iOS 13.0, *) {
            orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation
        } else {
            orientation = UIApplication.shared.statusBarOrientation
        }
        
        switch orientation {
        case .unknown:
            return .portrait
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            // UIInterfaceOrientationLandscapeLeft is equal to UIDeviceOrientationLandscapeRight
            return .landscapeRight
        case .landscapeRight:
            // UIInterfaceOrientationLandscapeRight is equal to UIDeviceOrientationLandscapeLeft
            return .landscapeLeft
        default:
            return .portrait
        }
    }
}

extension UIImage {
    func flipImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let bitmap = UIGraphicsGetCurrentContext()!

        bitmap.translateBy(x: size.width / 2, y: size.height / 2)
        bitmap.scaleBy(x: -1.0, y: -1.0)

        bitmap.translateBy(x: -size.width / 2, y: -size.height / 2)
        bitmap.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!

        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}
