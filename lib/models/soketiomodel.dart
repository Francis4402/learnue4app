import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:learnue4app/utils/key.dart';

class ChatSocketService {
  late IO.Socket socket;

  void connectSocket(
      String id, Null Function(dynamic data) param1, {
        required String userId,
        required String otherUserId,
        required Function(dynamic data) onMessageReceived,
        required Function(String messageId) onMessageDeleted,
      }) {
    socket = IO.io(Constants.uri, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      print('✅ Socket connected as $userId');
      final roomId = generateRoomId(userId, otherUserId);
      socket.emit('joinRoom', roomId);
    });

    socket.on('newMessage', (data) {
      print('📥 New message: ${data['message']}');
      onMessageReceived(data);
    });

    socket.on('messageDeleted', (data) {
      print('🗑️ Message deleted: ${data['_id']}');
      onMessageDeleted(data['_id'].toString());
    });

    socket.onDisconnect((_) {
      print('❌ Socket disconnected');
    });

    socket.onConnectError((data) {
      print('⚠️ Connect Error: $data');
    });
  }

  void sendMessage({
    required String senderId,
    required String receiverId,
    String? message,
    String? image,
    String? file,
    String? fileName,
  }) {
    final roomId = generateRoomId(senderId, receiverId);
    socket.emit('sendMessage', {
      'roomId': roomId,
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'image': image,
      'file': file,
      'fileName': fileName,
    });
  }

  void deleteMessage(String messageId, String roomId, String senderId) {
    socket.emit('deleteMessage', {
      '_id': messageId,
      'roomId': roomId,
      'senderId': senderId,
    });
  }

  void disconnect() {
    socket.disconnect();
    print('🔌 Socket manually disconnected');
  }

  String generateRoomId(String user1, String user2) {
    final sorted = [user1, user2]..sort();
    return 'room_${sorted.join("_")}';
  }
}
