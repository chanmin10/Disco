import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_room.dart';
import '../providers/translation_provider.dart';

const _kBorderColor = Color(0x14000000); // rgba(0,0,0,0.08)

class ChatSidebar extends ConsumerWidget {
  const ChatSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rooms = ref.watch(roomsProvider);
    final selectedId = ref.watch(selectedThemeProvider);

    return Container(
      color: const Color(0xFFF5F5F7),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                for (final room in rooms)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: _RoomRow(
                      room: room,
                      isActive: room.id == selectedId,
                      onTap: () {
                        ref.read(selectedThemeProvider.notifier).state = room.id;
                        ref.read(newRoomPickerOpenProvider.notifier).state = false;
                      },
                    ),
                  ),
              ],
            ),
          ),
          const _NewRoomButton(),
        ],
      ),
    );
  }
}

class _RoomRow extends StatelessWidget {
  final ChatRoom room;
  final bool isActive;
  final VoidCallback onTap;

  const _RoomRow({required this.room, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(7),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF0A84FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(
            room.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: isActive ? Colors.white : const Color(0xFF1D1D1F),
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _NewRoomButton extends ConsumerWidget {
  const _NewRoomButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _kBorderColor)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ref.read(newRoomPickerOpenProvider.notifier).state =
                !ref.read(newRoomPickerOpenProvider);
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Row(
              children: [
                Icon(Icons.add_circle_outline, size: 15, color: Color(0xFFA1A1A6)),
                SizedBox(width: 8),
                Text(
                  '새 채팅방',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFA1A1A6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The preset picker popover. Rendered by [MainScreen] as a screen-level
/// overlay so it can sit above the whole window and close on outside taps.
class NewRoomPopover extends ConsumerWidget {
  const NewRoomPopover({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final existingIds = ref.watch(roomsProvider).map((r) => r.id).toSet();

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final preset in newRoomPresets)
            InkWell(
              onTap: () {
                if (existingIds.contains(preset.id)) {
                  ref.read(selectedThemeProvider.notifier).state = preset.id;
                } else {
                  ref.read(roomsProvider.notifier).addRoom(preset);
                  ref.read(selectedThemeProvider.notifier).state = preset.id;
                }
                ref.read(newRoomPickerOpenProvider.notifier).state = false;
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: preset.tint,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      preset.name,
                      style: const TextStyle(fontSize: 12.5, color: Color(0xFF1D1D1F)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
