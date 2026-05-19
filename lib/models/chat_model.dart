class ChatMessageModel {
  ChatMessageModel({
    required this.message,
    required this.isUser,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String message;
  final bool isUser;
  final DateTime createdAt;
}
