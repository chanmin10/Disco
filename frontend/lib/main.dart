import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'providers/popup_provider.dart';
import 'screens/main_screen.dart';
import 'services/popup_window_service.dart';
import 'widgets/quick_popup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await hotKeyManager.unregisterAll();

  const windowOptions = WindowOptions(
    size: kMainWindowSize,
    minimumSize: Size(800, 600),
    center: true,
    title: 'DISCO',
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

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

class DiscoApp extends StatelessWidget {
  const DiscoApp({super.key});

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
          return isPopup ? const QuickPopup() : const MainScreen();
        },
      ),
    );
  }
}
