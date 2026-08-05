import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()

    // `flutterViewController.view` is a FlutterViewWrapper, not the actual
    // FlutterView — the real FlutterView (whose CAMetalLayer hardcodes
    // isOpaque and defaults to a black background) is a private subview
    // only reachable through this public FlutterViewController.backgroundColor
    // property. Setting `.view.layer` directly (an earlier attempt here)
    // touched the wrapper and had no effect. This must be set before
    // `self.contentViewController = flutterViewController` triggers
    // `loadView`, per Flutter's own documented pattern for this property.
    self.backgroundColor = NSColor.clear
    flutterViewController.backgroundColor = NSColor.clear

    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
