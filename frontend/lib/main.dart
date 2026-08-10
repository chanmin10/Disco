import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/popup_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/main_screen.dart';
import 'services/popup_window_service.dart';
import 'widgets/quick_popup.dart';

void main() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Supabase.initialize(
        url: const String.fromEnvironment('SUPABASE_URL'),
        anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
    ); 

    await windowManager.ensureInitialized();
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

    runApp(UncontrolledProviderScope(container: container, child: const DiscoApp()));
}

class DiscoApp extends StatefulWidget {
    const DiscoApp({super.key});

    @override
    State<DiscoApp> createState() => _DiscoAppState();
}

class _DiscoAppState extends State<DiscoApp> {
    Session? _session = Supabase.instance.client.auth.currentSession;
    late final StreamSubscription<AuthState> _authSubscription;

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

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: 'Disco',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0A84FF)),
            ),
            home: Consumer(
                builder: (context, ref, _) {
                final isPopup = ref.watch(isPopupWindowProvider);
                if (isPopup) return const QuickPopup();
                return _session != null ? const MainScreen() : const AuthScreen();
                },
            ),
        );
    }
}
