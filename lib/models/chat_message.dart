class ChatMessage {
  final String id;
  final String userMessage;
  final String aiResponse;
  final DateTime timestamp;
  final String userId;

  ChatMessage({
    required this.id,
    required this.userMessage,
    required this.aiResponse,
    required this.timestamp,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userMessage': userMessage,
      'aiResponse': aiResponse,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'userId': userId,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] ?? '',
      userMessage: map['userMessage'] ?? '',
      aiResponse: map['aiResponse'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      userId: map['userId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userMessage': userMessage,
      'aiResponse': aiResponse,
      'timestamp': timestamp,
      'userId': userId,
    };
  }

  factory ChatMessage.fromFirestore(Map<String, dynamic> data, String id) {
    return ChatMessage(
      id: id,
      userMessage: data['userMessage'] ?? '',
      aiResponse: data['aiResponse'] ?? '',
      timestamp: (data['timestamp'] as dynamic).toDate(),
      userId: data['userId'] ?? '',
    );
  }
}
