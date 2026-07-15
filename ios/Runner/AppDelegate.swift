import UIKit
import Flutter
import Photos

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    guard let controller = window?.rootViewController as? FlutterViewController else {
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    let fileSaverChannel = FlutterMethodChannel(
      name: "com.kytrademarks/file_saver",
      binaryMessenger: controller.binaryMessenger
    )
    fileSaverChannel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "saveImageFile" else {
        result(FlutterMethodNotImplemented)
        return
      }

      guard
        let arguments = call.arguments as? [String: Any],
        let filePath = arguments["filePath"] as? String,
        !filePath.isEmpty
      else {
        result(FlutterError(
          code: "invalid_file",
          message: "Missing image file path.",
          details: nil
        ))
        return
      }

      self?.saveImageToPhotos(filePath: filePath, result: result)
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func saveImageToPhotos(
    filePath: String,
    result: @escaping FlutterResult
  ) {
    let fileURL = URL(fileURLWithPath: filePath)
    guard FileManager.default.fileExists(atPath: filePath) else {
      result(FlutterError(
        code: "invalid_file",
        message: "The downloaded image file does not exist.",
        details: nil
      ))
      return
    }

    let saveImage = {
      PHPhotoLibrary.shared().performChanges({
        let request = PHAssetCreationRequest.forAsset()
        request.addResource(with: .photo, fileURL: fileURL, options: nil)
      }) { success, error in
        DispatchQueue.main.async {
          if success {
            result(fileURL.lastPathComponent)
          } else {
            result(FlutterError(
              code: "save_failed",
              message: error?.localizedDescription ?? "Could not save image to Photos.",
              details: nil
            ))
          }
        }
      }
    }

    if #available(iOS 14, *) {
      PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
        guard status == .authorized || status == .limited else {
          DispatchQueue.main.async {
            result(FlutterError(
              code: "permission_denied",
              message: "Photo library permission was denied.",
              details: nil
            ))
          }
          return
        }
        saveImage()
      }
    } else {
      PHPhotoLibrary.requestAuthorization { status in
        guard status == .authorized else {
          DispatchQueue.main.async {
            result(FlutterError(
              code: "permission_denied",
              message: "Photo library permission was denied.",
              details: nil
            ))
          }
          return
        }
        saveImage()
      }
    }
  }
}
