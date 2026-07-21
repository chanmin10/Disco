import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/translate_response.dart';
import '../models/chat_message.dart';
import '../models/vocab_item.dart';
import '../models/chat_room.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final inputProvider = StateProvider<String>((ref) => "");
final isLoadingProvider = StateProvider<bool>((ref) => false);
final translationProvider = StateProvider<TranslateResponse?>((ref) => null);
final selectedThemeProvider = StateProvider<String>((ref) => 'programming');
final isLeftSidebarOpen = StateProvider<bool>((ref) => true);
final isRightSidebarOpen = StateProvider<bool>((ref) => true);
final engineProvider = StateProvider<String>((ref) => 'general');
final newRoomPickerOpenProvider = StateProvider<bool>((ref) => false);

final defaultRooms = <ChatRoom>[
  ChatRoom(id: 'programming', name: '프로그래밍', tint: Color(0xFF5B8DEF)),
  ChatRoom(id: 'daily', name: '일상', tint: Color(0xFFF2B84B)),
  ChatRoom(id: 'business', name: '비즈니스', tint: Color(0xFFE8746C)),
];

final newRoomPresets = <ChatRoom>[
  ChatRoom(id: 'travel', name: '여행', tint: Color(0xFF4CAF6D)),
  ChatRoom(id: 'shopping', name: '쇼핑', tint: Color(0xFFC97B3D)),
  ChatRoom(id: 'school', name: '학교', tint: Color(0xFF3DBFC9)),
];

class RoomsNotifier extends StateNotifier<List<ChatRoom>> {
  RoomsNotifier() : super(List.of(defaultRooms));

  void addMessage(String roomId, ChatMessage message) {
    state = [
      for (final room in state)
        if (room.id == roomId)
          room.copyWith(messages: [...room.messages, message])
        else
          room,
    ];
  }

  void addVocab(String roomId, VocabItem vocab) {
    state = [
      for (final room in state)
        if (room.id == roomId)
          room.copyWith(vocab: [vocab, ...room.vocab])
        else
          room,
    ];
  }

  void clearVocabNew(String roomId, String vocabId) {
    state = [
      for (final room in state)
        if (room.id == roomId)
          room.copyWith(
            vocab: [
              for (final v in room.vocab)
                if (v.id == vocabId) v.copyWith(isNew: false) else v,
            ],
          )
        else
          room,
    ];
  }

  void addRoom(ChatRoom room) {
    if (state.any((r) => r.id == room.id)) return;
    state = [...state, room];
  }
}

final roomsProvider =
    StateNotifierProvider<RoomsNotifier, List<ChatRoom>>((ref) => RoomsNotifier());

final activeRoomProvider = Provider<ChatRoom>((ref) {
  final rooms = ref.watch(roomsProvider);
  final selectedId = ref.watch(selectedThemeProvider);
  return rooms.firstWhere((r) => r.id == selectedId, orElse: () => rooms.first);
});

final chatProvider = Provider<List<ChatMessage>>((ref) {
  return ref.watch(activeRoomProvider).messages;
});

final vocabListProvider = Provider<List<VocabItem>>((ref) {
  return ref.watch(activeRoomProvider).vocab;
});
