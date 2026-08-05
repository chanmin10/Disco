import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../providers/popup_provider.dart';

/// Shared container so the global hotkey handler (registered in main(),
/// outside the widget tree) and the popup widget read/write the same
/// provider state as the rest of the app.
final ProviderContainer container = ProviderContainer();

const Size kMainWindowSize = Size(1180, 760);
const Size kPopupBaseSize = Size(420, 150);

/// Drives the single native window between its two shapes: the full chat UI
/// and the compact always-on-top popup. There's no multi-window plugin here,
/// so "opening the popup" means the app's one window is resized, repositioned
/// to the top-right of the screen, and made frameless/always-on-top; closing
/// it restores whatever bounds/chrome the main window had before.
class PopupWindowService {
  PopupWindowService(this._container);
  final ProviderContainer _container;

  Rect? _savedMainBounds;
  double _lastHeight = kPopupBaseSize.height;

  Future<Rect> _popupBounds(Size size) async {
    final display = ui.PlatformDispatcher.instance.views.first.display;
    final screenSize = display.size / display.devicePixelRatio;
    final dx = screenSize.width - size.width - 20;
    return Rect.fromLTWH(dx, 36, size.width, size.height);
  }

  /// Toggled by the global hotkey: opens the popup if it's closed, closes it
  /// if it's already open (so pressing the shortcut again dismisses it).
  Future<void> toggle() async {
    if (_container.read(isPopupWindowProvider)) {
      await hide();
    } else {
      await show();
    }
  }

  Future<void> show() async {
    if (_container.read(isPopupWindowProvider)) {
      await windowManager.focus();
      return;
    }

    _savedMainBounds = await windowManager.getBounds();
    _lastHeight = kPopupBaseSize.height;
    _container.read(popupControllerProvider.notifier).reset();

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
    await windowManager.setSkipTaskbar(true);
    await windowManager.setBounds(await _popupBounds(kPopupBaseSize));
    await windowManager.setAlwaysOnTop(true);

    // Flip to the popup widget only after the window is already sized for
    // it. Doing this earlier let QuickPopup (or worse, MainScreen on the
    // way back in hide()) render for a frame at the wrong window size —
    // that's what was causing the title bar's RenderFlex to overflow.
    _container.read(isPopupWindowProvider.notifier).state = true;

    await windowManager.show();
    await windowManager.focus();
  }

  Future<void> hide() async {
    final isOpen = _container.read(isPopupWindowProvider);
    if (!isOpen) return;

    await windowManager.setAlwaysOnTop(false);
    await windowManager.setSkipTaskbar(false);
    await windowManager.setResizable(true);
    await windowManager.setTitleBarStyle(TitleBarStyle.normal);
    await windowManager.setBackgroundColor(Colors.white);
    if (_savedMainBounds != null) {
      await windowManager.setBounds(_savedMainBounds!);
    }

    // See the comment in show(): flip back to MainScreen only once the
    // window is already restored to its full size.
    _container.read(isPopupWindowProvider.notifier).state = false;

    await windowManager.hide();
  }

  /// Resizes the window's height to match the popup card's actual rendered
  /// content (called after every layout pass) so long AI responses aren't
  /// clipped and short ones don't leave the window oversized. Width stays
  /// fixed; height is clamped between the empty-state minimum and just shy
  /// of the screen height so the card never grows off-screen.
  Future<void> syncSize(double contentHeight) async {
    if (!_container.read(isPopupWindowProvider)) return;
    final display = ui.PlatformDispatcher.instance.views.first.display;
    final screenHeight = display.size.height / display.devicePixelRatio;
    final maxHeight = screenHeight - 72;
    final target = contentHeight.clamp(kPopupBaseSize.height, maxHeight);
    if ((target - _lastHeight).abs() < 1) return;
    _lastHeight = target;
    await windowManager.setSize(Size(kPopupBaseSize.width, target));
  }
}

final PopupWindowService popupWindowService = PopupWindowService(container);
