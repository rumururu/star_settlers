import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "FeedbackChannel")
    let channel = FlutterMethodChannel(name: "star_settlers/feedback", binaryMessenger: registrar!.messenger())
    channel.setMethodCallHandler { call, result in
      guard call.method == "send" else {
        result(FlutterMethodNotImplemented)
        return
      }
      let args = call.arguments as? [String: Any]
      AppDelegate.sendFeedback(subject: args?["subject"] as? String, result)
    }
  }

  /// 개발자에게 메일로 피드백을 보낸다. 본문 아래에 앱 버전·기기·iOS 버전을 미리 채운다.
  /// 메일 앱을 못 열면 false → 화면에서 주소를 알려 준다.
  /// `subject`: Dart 쪽이 넘긴 현지화 제목(선택). 비어 있으면 기존 한국어 제목을 쓴다.
  private static func sendFeedback(subject: String?, _ result: @escaping FlutterResult) {
    let info = Bundle.main.infoDictionary ?? [:]
    let appName = (info["CFBundleDisplayName"] ?? info["CFBundleName"]) as? String ?? "Star Settlers"
    let version = info["CFBundleShortVersionString"] as? String ?? "?"
    let build = info["CFBundleVersion"] as? String ?? "?"
    var sys = utsname()
    uname(&sys)
    let model = withUnsafePointer(to: &sys.machine) {
      $0.withMemoryRebound(to: CChar.self, capacity: 1) { String(cString: $0) }
    }
    let body = "\n\n----------\n\(appName) \(version) (\(build))\nApple \(model)\niOS \(UIDevice.current.systemVersion)\n"
    let trimmed = subject?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    let mailSubject = trimmed.isEmpty ? "[\(appName)] 피드백" : trimmed
    var comps = URLComponents()
    comps.scheme = "mailto"
    comps.path = "mkideabox.feedback@gmail.com"
    comps.queryItems = [
      URLQueryItem(name: "subject", value: mailSubject),
      URLQueryItem(name: "body", value: body),
    ]
    guard let url = comps.url, UIApplication.shared.canOpenURL(url) else {
      result(false)
      return
    }
    UIApplication.shared.open(url) { ok in result(ok) }
  }
}
