import Cocoa
import FlutterMacOS
import desktop_multi_window

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

    // Each window the popup (or any future secondary window) opens gets its
    // own separate Flutter engine, so plugins registered on the main
    // window's engine above — window_manager, hotkey_manager, etc. — aren't
    // automatically available there too. This registers them for every new
    // window desktop_multi_window creates.
    FlutterMultiWindowPlugin.setOnWindowCreatedCallback { controller in
      RegisterGeneratedPlugins(registry: controller)
    }

    super.awakeFromNib()
  }
}
