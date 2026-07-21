class ChatMessage {
  final String id;
  final String role; // 'user' or 'bot'
  final String text;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.text,
  });
}
