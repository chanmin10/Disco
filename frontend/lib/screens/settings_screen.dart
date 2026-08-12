import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Opens the settings panel as a modal dialog centered over [context]'s
/// current screen. Dismisses on outside-click or Escape (both handled by
/// Flutter's default `showDialog` barrier behavior — no extra wiring needed).
Future<void> showSettingsDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.25),
    builder: (_) => const SettingsDialog(),
  );
}

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  Future<void> _logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    // main.dart's onAuthStateChange listener swaps the app's root screen to
    // AuthScreen once the session clears — popping just dismisses this
    // dialog so that swap is what's left visible underneath.
    if (context.mounted) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final email = Supabase.instance.client.auth.currentUser?.email ?? '알 수 없음';

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            width: 480,
            height: 560,
            decoration: BoxDecoration(
              color: const Color(0xFFEDEDF0).withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
            ),
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    children: [
                      _SettingsSection(
                        header: '계정',
                        rows: [
                          _SettingsRow(
                            iconBg: const Color(0xFFFF9F0A),
                            icon: Icons.person_rounded,
                            title: email,
                            trailing: SizedBox(
                              height: 30,
                              child: OutlinedButton(
                                onPressed: () => _logout(context),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0x59FF3B30)),
                                  foregroundColor: const Color(0xFFFF3B30),
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                                ),
                                child: const Text('로그아웃', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      _SettingsSection(
                        header: '단축키',
                        rows: [
                          _SettingsRow(
                            iconBg: const Color(0xFF5E5CE6),
                            icon: Icons.keyboard_command_key_rounded,
                            title: '전역 단축키',
                            subtitle: '번역 팝업 열기',
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(color: const Color(0xFFF0F0F2), borderRadius: BorderRadius.circular(6)),
                              child: const Text(
                                '⇧⌥Space',
                                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF1D1D1F)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      _SettingsSection(
                        header: '정보',
                        rows: const [
                          _SettingsRow(
                            iconBg: Color(0xFF8E8E93),
                            icon: Icons.info_outline_rounded,
                            title: '버전',
                            trailing: Text('1.0.0 (MVP)', style: TextStyle(fontSize: 12.5, color: Color(0xFF86868B))),
                          ),
                          _SettingsRow(
                            iconBg: Color(0xFF8E8E93),
                            icon: Icons.info_outline_rounded,
                            title: '문의',
                            trailing: Text('support@disco.app', style: TextStyle(fontSize: 12.5, color: Color(0xFF86868B))),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black.withValues(alpha: 0.08))),
      ),
      child: Stack(
        children: [
          const Center(
            child: Text(
              '환경설정',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF1D1D1F)),
            ),
          ),
          Positioned(
            right: 10,
            top: 0,
            bottom: 0,
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(11),
                  onTap: () => Navigator.of(context).maybePop(),
                  child: const SizedBox(
                    width: 22,
                    height: 22,
                    child: Icon(Icons.close_rounded, size: 15, color: Color(0xFF6E6E73)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String header;
  final List<_SettingsRow> rows;

  const _SettingsSection({required this.header, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
            child: Text(header, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF86868B))),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [BoxShadow(color: Color(0x0B000000), blurRadius: 0, spreadRadius: 1)],
            ),
            child: Column(
              children: [
                for (var i = 0; i < rows.length; i++)
                  Container(
                    decoration: BoxDecoration(
                      border: i == rows.length - 1
                          ? null
                          : const Border(bottom: BorderSide(color: Color(0x12000000))),
                    ),
                    child: rows[i],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final Color iconBg;
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget trailing;

  const _SettingsRow({
    required this.iconBg,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(7)),
            child: Icon(icon, size: 15, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF1D1D1F)),
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Text(subtitle!, style: const TextStyle(fontSize: 11.5, color: Color(0xFF86868B))),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          trailing,
        ],
      ),
    );
  }
}
