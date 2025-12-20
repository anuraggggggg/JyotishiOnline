class ChatMessage {
  final int id;
  final String roomId;
  final String senderId;     // USER ID
  final String receiverId;   // USER ID
  final String content;
  final DateTime createdAt;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.createdAt,
    required this.isRead,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? 0,
      roomId: json['room_id'] ?? '',

      // 🔥 FIXED KEYS
      senderId: json['sender_user_id'] ?? '',
      receiverId: json['receiver_user_id'] ?? '',

      content: json['content'] ?? '',
      createdAt:
      DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      isRead: json['is_read'] ?? false,
    );
  }
}
