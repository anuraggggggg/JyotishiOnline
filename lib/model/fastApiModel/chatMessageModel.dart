class ChatMessage {
  final int id;
  final String fromId;
  final String toId;
  final String message;
  final DateTime timestamp;
   bool isRead;

  ChatMessage({
    required this.id,
    required this.fromId,
    required this.toId,
    required this.message,
    required this.timestamp,
    required this.isRead,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      fromId: json['from_id'].toString(),
      toId: json['to_id'].toString(),
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['is_read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "from_id": fromId,
      "to_id": toId,
      "message": message,
      "timestamp": timestamp.toIso8601String(),
      "is_read": isRead,
    };
  }
}
