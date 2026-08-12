import 'dart:async';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth_screen.dart';
import 'screens/main_screen.dart';
import 'screens/settings_screen.dart';
import 'services/popup_window_service.dart';
import 'widgets/quick_popup.dart';

/// The arguments string [PopupWindowService.open] passes to
/// [WindowController.create] — how the popup's own boot sequence (below)
/// tells itself apart from the main window on the same entrypoint.
const _kPopupWindowArgument = 'popup';

Future<void> main(List<String> args) async {
    WidgetsFlutterBinding.ensureInitialized();
    await windowManager.ensureInitialized();

    // Every window created by desktop_multi_window (the popup included) runs
    // this exact same entrypoint in its own fresh engine — this is how each
    // one figures out which app it's actually supposed to boot into.
    final windowController = await WindowController.fromCurrentEngine();
    if (windowController.arguments == _kPopupWindowArgument) {
        await _runPopupWindow(windowController);
        return;
    }
    await _runMainWindow();
}

Future<void> _runPopupWindow(WindowController controller) async {
    await Supabase.initialize(
        url: const String.fromEnvironment('SUPABASE_URL'),
        anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
    );

    // The main window has no direct handle into this window's own engine, so
    // it asks over this channel instead — see PopupWindowService.close().
    await controller.setWindowMethodHandler((call) async {
        if (call.method == 'window_close') return popupSelfWindow.close();
        throw MissingPluginException('Not implemented: ${call.method}');
    });

    runApp(const ProviderScope(child: _PopupWindowApp()));
}

Future<void> _runMainWindow() async {
    await Supabase.initialize(
        url: const String.fromEnvironment('SUPABASE_URL'),
        anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
    );

    await hotKeyManager.unregisterAll();

    const windowOptions = WindowOptions(
        size: kMainWindowSize,
        minimumSize: Size(800, 600),
        center: true,
        title: 'DISCO',
        // Hides the native title bar background/divider while keeping the
        // traffic-light buttons floating at the top-left, so _TitleBar in
        // main_screen.dart can draw one merged row instead of a separate
        // native bar sitting above a second, Flutter-drawn one.
        titleBarStyle: TitleBarStyle.hidden,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
    });
    await loadNativeTitleBarHeight();

    await hotKeyManager.register(
        HotKey(
            key: PhysicalKeyboardKey.space,
            modifiers: [HotKeyModifier.shift, HotKeyModifier.alt],
            scope: HotKeyScope.system,
        ),
        keyDownHandler: (_) => popupWindowService.toggle(),
    );

    runApp(const ProviderScope(child: DiscoApp()));
}

class DiscoApp extends StatefulWidget {
    const DiscoApp({super.key});

    @override
    State<DiscoApp> createState() => _DiscoAppState();
}

class _DiscoAppState extends State<DiscoApp> {
    Session? _session = Supabase.instance.client.auth.currentSession;
    late final StreamSubscription<AuthState> _authSubscription;
    final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

    @override
    void initState() {
        super.initState();
        _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
            setState(() => _session = data.session);
        });
    }

    @override
    void dispose() {
        _authSubscription.cancel();
        super.dispose();
    }

    // `currentContext` doubles as a valid context for showDialog: Navigator.of
    // special-cases a context that IS the Navigator's own element — needed
    // since the macOS app menu lives above the Navigator and has no
    // BuildContext of its own.
    void _openPreferences() {
        final context = _navigatorKey.currentContext;
        if (context != null) showSettingsDialog(context);
    }

    @override
    Widget build(BuildContext context) {
        return PlatformMenuBar(
            menus: <PlatformMenuItem>[
                PlatformMenu(
                    label: 'Disco',
                    menus: <PlatformMenuItem>[
                        const PlatformProvidedMenuItem(type: PlatformProvidedMenuItemType.about),
                        PlatformMenuItem(
                            label: '환경설정…',
                            shortcut: const SingleActivator(LogicalKeyboardKey.comma, meta: true),
                            onSelected: _openPreferences,
                        ),
                        const PlatformProvidedMenuItem(type: PlatformProvidedMenuItemType.quit),
                    ],
                ),
            ],
            child: MaterialApp(
                navigatorKey: _navigatorKey,
                title: 'Disco',
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                    useMaterial3: true,
                    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0A84FF)),
                ),
                home: _session != null ? const MainScreen() : const AuthScreen(),
            ),
        );
    }
}

/// The popup's own tiny app root — a completely separate window/engine from
/// [DiscoApp], with its own MaterialApp and provider container. It has no
/// session-based routing of its own: ApiService just calls the backend
/// directly, and Supabase rehydrates whatever session was last persisted to
/// disk by the main window.
class _PopupWindowApp extends StatefulWidget {
    const _PopupWindowApp();

    @override
    State<_PopupWindowApp> createState() => _PopupWindowAppState();
}

class _PopupWindowAppState extends State<_PopupWindowApp> {
    @override
    void initState() {
        super.initState();
        popupSelfWindow.configure();
    }

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0A84FF)),
            ),
            home: const QuickPopup(),
        );
    }
}
