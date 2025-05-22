class MessageModel {
  late final String message;
  late final String sender;
  late final String receiver;
  late final String? messageId;
  late final DateTime timestamp;
  late final bool isSeenByReceiver;
  late final bool? isImage;

  MessageModel(
      {
        required this.message,
        required this.sender,
        required this.receiver,
        this.messageId,
        required this.timestamp,
        this.isImage,
        required this.isSeenByReceiver
      });
}