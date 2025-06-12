class ChatMessage {
  final String id;
  final String roomId;
  final String senderId;
  final String receiverId;
  final String? message;
  final String? image;
  final String? fileName;
  final bool isRead;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.receiverId,
    this.message,
    this.image,
    this.fileName,
    required this.isRead,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['_id'],
      roomId: json['roomId'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      message: json['message'],
      image: json['image'],
      fileName: json['fileName'],
      isRead: json['isRead'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'roomId': roomId,
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'image': image,
      'fileName': fileName,
      'isRead': isRead,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
