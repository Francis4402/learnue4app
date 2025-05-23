import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:learnue4app/models/user.dart';
import 'package:learnue4app/utils/key.dart';
import 'package:learnue4app/models/soketiomodel.dart';

class ChatScreen extends StatefulWidget {
  final User currentUser;
  final Map<String, dynamic> otherUser;

  const ChatScreen({
    super.key,
    required this.currentUser,
    required this.otherUser,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> messages = [];
  late ChatSocketService socketService;

  @override
  void initState() {
    super.initState();
    socketService = ChatSocketService();

    // Connect to socket and handle incoming messages
    socketService.connectSocket(
      widget.currentUser.id,
          (data) {
        setState(() {
          messages.add(data);
        });
      },
      userId: widget.currentUser.id,
      otherUserId: widget.otherUser['_id'],
      onMessageReceived: (data) {
        setState(() {
          messages.add(data);
        });
      },
    );


    // Load old chat messages
    loadMessages();

    // Join room
    final roomId = socketService.generateRoomId(
      widget.currentUser.id,
      widget.otherUser['_id'],
    );
    socketService.socket.emit('joinRoom', roomId);
  }

  @override
  void dispose() {
    socketService.disconnect();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  Future<void> loadMessages() async {
    final user1 = widget.currentUser.id;
    final user2 = widget.otherUser['_id'];

    final url = Uri.parse('${Constants.uri}/api/messages/$user1/$user2');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List decoded = jsonDecode(response.body);
      setState(() {
        messages.addAll(decoded.cast<Map<String, dynamic>>());
      });
    } else {
      print('⚠️ Failed to load messages: ${response.body}');
    }
  }

  void sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final newMessage = {
      'senderId': widget.currentUser.id,
      'receiverId': widget.otherUser['_id'],
      'message': text,
      'createdAt': DateTime.now().toIso8601String(),
    };

    // Add message locally for instant UI feedback
    setState(() {
      messages.add(newMessage);
    });
    scrollToBottom();

    // Emit message via socket
    socketService.sendMessage(
      senderId: widget.currentUser.id,
      receiverId: widget.otherUser['_id'],
      message: text,
    );

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat with ${widget.otherUser['name']}"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg['senderId'] == widget.currentUser.id;

                return Align(
                  alignment:
                  isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 14),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(msg['message'] ?? '', style: const TextStyle(
                        color: Colors.black, fontSize: 16),),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration:
                    const InputDecoration(hintText: 'Type a message...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
