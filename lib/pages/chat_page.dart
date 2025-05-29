import 'dart:io';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:learnue4app/models/user_model.dart';
import 'package:learnue4app/utils/key.dart';
import 'package:learnue4app/models/soketiomodel.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';


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

  Future<void> _downloadFile({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final isMounted = mounted;

    final status = await Permission.storage.request();
    if (!status.isGranted) {
      if (isMounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Storage permission denied')),
        );
      }
      return;
    }

    final dir = await getExternalStorageDirectory();
    if (dir == null) return;

    final filePath = '${dir.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(bytes);

    if (isMounted) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Saved to $filePath')),
      );
    }

    await OpenFile.open(filePath);
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
      final dateTime = createdAt is String
          ? DateTime.parse(createdAt)
          : DateTime.fromMillisecondsSinceEpoch(createdAt);
      return DateFormat('hh:mm a').format(dateTime);
    } catch (e) {
      return '';
    }
  }

  Widget buildMessageWidget(Map<String, dynamic> msg, bool isMe) {
    String timeString = getFormattedTime(msg['timestamp'] ?? msg['createdAt']);

    Widget content;

    if (msg.containsKey('image') && msg['image'] != null && msg['image'] is String) {
      try {
        final bytes = base64Decode(msg['image']);
        content = Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => _downloadFile(
                bytes: bytes,
                fileName: 'image_${DateTime.now().millisecondsSinceEpoch}.jpg',
              ),
              child: Image.memory(bytes, width: 200),
            ),
            const SizedBox(height: 4),
            Text(timeString, style: const TextStyle(fontSize: 10, color: Colors.black)),
            const Text('Tap image to download', style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        );
      } catch (_) {
        content = const Text("⚠️ Failed to load image.");
      }
    } else if (msg.containsKey('file') &&
        msg['file'] != null &&
        msg['file'] is String &&
        msg.containsKey('fileName') &&
        msg['fileName'] != null) {
      try {
        final bytes = base64Decode(msg['file']);
        content = Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => _downloadFile(bytes: bytes, fileName: msg['fileName']),
              child: const Icon(Icons.insert_drive_file, size: 40, color: Colors.blueAccent),
            ),
            Text(msg['fileName'], style: const TextStyle(fontSize: 14, color: Colors.black)),
            const Text('Tap to download', style: TextStyle(fontSize: 10, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(timeString, style: const TextStyle(fontSize: 10, color: Colors.black)),
          ],
        );
      } catch (_) {
        content = const Text("⚠️ Failed to load file.");
      }
    } else if (msg.containsKey('message') && msg['message'] != null && msg['message'] is String) {
      content = Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            msg['message'],
            style: const TextStyle(color: Colors.black, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(timeString, style: const TextStyle(fontSize: 10, color: Colors.black)),
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
                      ? () async {
                          final messageId = msg['_id']?.toString();
                          if (messageId == null || messageId.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content: Text(
                                    'Cannot delete message - invalid ID')));
                            return;
                          }

                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Message?'),
                              content: const Text(
                                  'This will permanently remove the message'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete',
                                      style: TextStyle(color: Colors.red)),
                                )
                              ],
                            ),
                          );

                          if (confirmed == true) {
                            final roomId = socketService.generateRoomId(
                              widget.currentUser.id!,
                              widget.otherUser['_id'],
                            );

                            // Optimistic UI update
                            setState(() {
                              messages
                                  .removeWhere((m) => m['_id'] == messageId);
                            });

                            // Send deletion request
                            socketService.deleteMessage(
                                messageId, roomId, widget.currentUser.id!);
                          }
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
