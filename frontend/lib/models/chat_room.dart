import 'package:flutter/material.dart';
import 'chat_message.dart';
import 'vocab_item.dart';

class ChatRoom {
  final String id;
  final String name;
  final Color tint;
  final List<ChatMessage> messages;
  final List<VocabItem> vocab;

  const ChatRoom({
    required this.id,
    required this.name,
    required this.tint,
    this.messages = const [],
    this.vocab = const [],
  });

  ChatRoom copyWith({
    List<ChatMessage>? messages,
    List<VocabItem>? vocab,
  }) {
    return ChatRoom(
      id: id,
      name: name,
      tint: tint,
      messages: messages ?? this.messages,
      vocab: vocab ?? this.vocab,
    );
  }
}
