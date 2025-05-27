import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:learnue4app/models/user_model.dart';
import 'package:learnue4app/utils/key.dart';
import 'package:learnue4app/models/soketiomodel.dart';
import 'package:intl/intl.dart';

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
      widget.currentUser.id!,
      (data) {
        setState(() {
          messages.add(data);
        });
      },
      userId: widget.currentUser.id!,
      otherUserId: widget.otherUser['_id'],
      onMessageReceived: (data) {
        setState(() {
          messages.add(data);
        });
      },
      onMessageDeleted: (String messageId) {
        setState(() {
          messages.removeWhere((m) => m['_id'] == messageId);
        });
      },
    );

    // Load old chat messages
    loadMessages();

    // Join room
    final roomId = socketService.generateRoomId(
      widget.currentUser.id!,
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


    setState(() {
      messages.add(newMessage);
    });
    scrollToBottom();

    // Emit message via socket
    socketService.sendMessage(
      senderId: widget.currentUser.id!,
      receiverId: widget.otherUser['_id'],
      message: text,
    );

    _messageController.clear();
  }

  Future<void> pickAndSendImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final newMessage = {
        'senderId': widget.currentUser.id,
        'receiverId': widget.otherUser['_id'],
        'image': base64Image,
        'createdAt': DateTime.now().toIso8601String(),
      };

      setState(() {
        messages.add(newMessage);
        scrollToBottom();
      });

      socketService.sendMessage(
        senderId: widget.currentUser.id!,
        receiverId: widget.otherUser['_id'],
        message: '',
        image: base64Image,
      );
    }
  }

  Future<void> pickAndSendFile() async {
    final result = await FilePicker.platform.pickFiles(withData: true);

    if (result != null && result.files.single.bytes != null) {
      final file = result.files.single;
      final base64File = base64Encode(file.bytes!);

      final newMessage = {
        'senderId': widget.currentUser.id,
        'receiverId': widget.otherUser['_id'],
        'file': base64File,
        'fileName': file.name,
        'createdAt': DateTime.now().toIso8601String(),
      };

      setState(() => messages.add(newMessage));
      scrollToBottom();

      socketService.sendMessage(
        senderId: widget.currentUser.id!,
        receiverId: widget.otherUser['_id'],
        message: '',
        file: base64File,
        fileName: file.name,
      );
    }
  }

  String getFormattedTime(dynamic createdAt) {
    try {
      if (createdAt == null) return '';
      final dateTime = createdAt is String ?
      DateTime.parse(createdAt) : DateTime.fromMillisecondsSinceEpoch(createdAt);
      return DateFormat('hh:mm a').format(dateTime);
    } catch (e) {
      return '';
    }
  }

  Widget buildMessageWidget(Map<String, dynamic> msg, bool isMe) {
    String timeString = getFormattedTime(msg['timestamp'] ?? msg['createdAt']);

    Widget content;

    if (msg.containsKey('image') &&
        msg['image'] != null &&
        msg['image'] is String) {
      try {
        final bytes = base64Decode(msg['image']);
        content = Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Image.memory(bytes, width: 200),
            const SizedBox(height: 4),
            Text(timeString,
                style: const TextStyle(fontSize: 10, color: Colors.black)),
          ],
        );
      } catch (e) {
        content = const Text("⚠️ Failed to load image.");
      }
    } else if (msg.containsKey('file') &&
        msg['file'] != null &&
        msg['file'] is String &&
        msg.containsKey('fileName') &&
        msg['fileName'] != null) {
      content = Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          const Icon(Icons.insert_drive_file, size: 40),
          Text(msg['fileName'] ?? '',
              style: const TextStyle(fontSize: 14, color: Colors.black)),
          const SizedBox(height: 4),
          Text(timeString,
              style: const TextStyle(fontSize: 10, color: Colors.black)),
        ],
      );
    } else if (msg.containsKey('message') &&
        msg['message'] != null &&
        msg['message'] is String) {
      content = Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            msg['message'],
            style: const TextStyle(color: Colors.black, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(timeString,
              style: const TextStyle(fontSize: 10, color: Colors.black)),
        ],
      );
    } else {
      content = const Text(
        "⚠️ Unknown message format.",
        style: TextStyle(color: Colors.red),
      );
    }

    return content;
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
              controller: _scrollController,
              padding: const EdgeInsets.all(10),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg['senderId'] == widget.currentUser.id;

                return GestureDetector(
                  onLongPress: isMe
                      ? () {
                          final roomId = socketService.generateRoomId(
                              widget.currentUser.id!, widget.otherUser['_id']);

                          showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                    title: const Text('Delete Message?'),
                                    content: const Text(
                                        'Do you want to delete this message?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          socketService.deleteMessage(msg['_id'], roomId, widget.currentUser.id!);
                                        },
                                        child: const Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel'),
                                      ),
                                    ],
                                  ));
                        }
                      : null,
                  child: Align(
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
                      child: buildMessageWidget(msg, isMe),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: pickAndSendImage,
                ),
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: pickAndSendFile,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      backgroundColor: Colors.blueGrey),
                  onPressed: sendMessage,
                  child: const Icon(Icons.send, color: Colors.blue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
