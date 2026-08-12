import 'dart:async';
import 'dart:ui' as ui;

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

const Size kMainWindowSize = Size(874, 600);
const Size kPopupBaseSize = Size(420, 150);

/// The OS's actual native title-bar height, queried once at startup (see
/// [loadNativeTitleBarHeight] in main()). macOS keeps the traffic-light
/// buttons vertically centered within this exact zone regardless of how
/// tall our own custom title bar row is — rather than fighting that via
/// fragile AppKit view repositioning, _TitleBar (main_screen.dart) aligns
/// its own toggle button to match this known value instead. 28 is the
/// modern macOS default, used only until the real value loads.
double nativeTitleBarHeight = 28;

Future<void> loadNativeTitleBarHeight() async {
  nativeTitleBarHeight = (await windowManager.getTitleBarHeight()).toDouble();
}

/// Where the popup should sit: the top-right corner of the screen, computed
/// fresh each time since it no longer inherits any position from the main
/// window (they're independent windows now).
Future<Rect> popupBounds(Size size) async {
  final display = ui.PlatformDispatcher.instance.views.first.display;
  final screenSize = display.size / display.devicePixelRatio;
  final dx = screenSize.width - size.width - 20;
  return Rect.fromLTWH(dx, 36, size.width, size.height);
}

/// Runs on the main window: opens/closes the global-hotkey popup as a real,
/// separate OS window with its own Flutter engine (via desktop_multi_window)
/// so toggling it never touches this window's own size, position, or
/// visibility — the popup configures and shows itself; see [PopupSelfWindow]
/// and main.dart's popup entrypoint.
class PopupWindowService {
  WindowController? _controller;

  // Lives for the app's whole lifetime, same as this singleton — never
  // cancelled, deliberately.
  PopupWindowService() {
    onWindowsChanged.listen((_) => _forgetIfClosed());
  }

  /// The popup can close itself (e.g. via Escape) without asking this window
  /// first. This reconciles our tracked controller once that happens, so the
  /// next hotkey press creates a fresh window instead of trying to close one
  /// that's already gone.
  Future<void> _forgetIfClosed() async {
    final controller = _controller;
    if (controller == null) return;
    final all = await WindowController.getAll();
    if (!all.any((c) => c.windowId == controller.windowId)) {
      _controller = null;
    }
  }

  Future<void> toggle() => _controller != null ? close() : open();

  Future<void> open() async {
    if (_controller != null) return;
    // Created hidden so the popup can fully configure its own frameless,
    // transparent, positioned chrome before it ever becomes visible —
    // avoiding a flash of a default titled window.
    _controller = await WindowController.create(
      const WindowConfiguration(arguments: 'popup'),
    );
  }

  Future<void> close() async {
    final controller = _controller;
    if (controller == null) return;
    _controller = null;
    await controller.invokeMethod('window_close');
  }
}

final PopupWindowService popupWindowService = PopupWindowService();

/// Runs inside the popup's own window/engine: gives it its floating,
/// frameless, always-on-top look and grows/shrinks it to fit its content.
/// window_manager calls made from here always target this window itself,
/// never the main window.
class PopupSelfWindow {
  double _lastHeight = kPopupBaseSize.height;

  Future<void> configure() async {
    await windowManager.setAsFrameless();
    // window_manager's setAsFrameless() sets NSWindow.isOpaque = true as a
    // side effect, which makes a "clear" backgroundColor paint solid black
    // instead of true transparency (macOS only honors clear/alpha on
    // non-opaque windows). setTitleBarStyle(hidden) is the only other call
    // in the plugin that flips isOpaque back to false, so it has to run
    // here even though we don't want an actual title bar.
    await windowManager.setTitleBarStyle(TitleBarStyle.hidden, windowButtonVisibility: false);
    await windowManager.setHasShadow(false);
    await windowManager.setBackgroundColor(Colors.transparent);
    await windowManager.setResizable(false);
    // Deliberately not calling setSkipTaskbar(true) here: it maps to
    // NSApplication.setActivationPolicy, which is process-wide, not
    // per-window. The old single-window popup could get away with it since
    // the main window was never on-screen at the same time; now that both
    // are real, independent windows, doing that would knock the main
    // window's Dock icon out too for as long as the popup is open.
    await windowManager.setBounds(await popupBounds(kPopupBaseSize));
    await windowManager.setAlwaysOnTop(true);
    await windowManager.show();
    await windowManager.focus();
  }

  /// Resizes the window's height to match the popup card's actual rendered
  /// content (called after every layout pass) so long AI responses aren't
  /// clipped and short ones don't leave the window oversized. Width stays
  /// fixed; height is clamped between the empty-state minimum and just shy
  /// of the screen height so the card never grows off-screen.
  Future<void> syncSize(double contentHeight) async {
    final display = ui.PlatformDispatcher.instance.views.first.display;
    final screenHeight = display.size.height / display.devicePixelRatio;
    final maxHeight = screenHeight - 72;
    final target = contentHeight.clamp(kPopupBaseSize.height, maxHeight);
    if ((target - _lastHeight).abs() < 1) return;
    _lastHeight = target;
    await windowManager.setSize(Size(kPopupBaseSize.width, target));
  }

  Future<void> close() => windowManager.close();
}

final PopupSelfWindow popupSelfWindow = PopupSelfWindow();
