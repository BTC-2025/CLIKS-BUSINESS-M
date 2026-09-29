import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    let urlChannel = FlutterMethodChannel(
      name: "com.cliks.business/url_launcher",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    urlChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
      if call.method == "openUrl",
         let args = call.arguments as? [String: Any],
         let urlString = args["url"] as? String,
         let url = URL(string: urlString) {
        let success = NSWorkspace.shared.open(url)
        result(success)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    super.awakeFromNib()
  }
}
