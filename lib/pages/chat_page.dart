import 'package:flutter/material.dart';
import 'package:learnue4app/models/user_model.dart';
import 'package:learnue4app/utils/key.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatScreen extends StatefulWidget {
  const ChatScreen(
      {super.key, required this.currentUser, required this.otherUser});

  final User currentUser;
  final Map<String, dynamic> otherUser;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late IO.Socket socket;
  late bool sendButton = false;

  void connect() {
    socket = IO.io(Constants.uri, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket.connect();
    socket.onConnect((data) => print("Connected"));
  }

  void sendMessage(String message, int senderId, int receiverId) {
    socket.emit("message", {
      "message": message, "senderId": senderId, "reciverId": receiverId
    });
  }

  @override
  void initState() {
    connect();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${widget.otherUser['name']}".toUpperCase(),
              style: const TextStyle(fontSize: 18),
            ),
            const Text(
              'last seen today at 12.00',
              style: TextStyle(fontSize: 12),
            )
          ],
        ),
        elevation: 5,
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            ListView(),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 60,
                    child: Card(
                      margin:
                          const EdgeInsets.only(left: 2, right: 2, bottom: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      child: TextFormField(
                        controller: _messageController,
                        textAlignVertical: TextAlignVertical.center,
                        keyboardType: TextInputType.multiline,
                        maxLines: 5,
                        minLines: 1,
                        onChanged: (value) {
                          if(value.isNotEmpty) {
                            setState(() {
                              sendButton = true;
                            });
                          } else {
                            setState(() {
                              sendButton = false;
                            });
                          }
                        },
                        decoration: InputDecoration(
                            hintText: "Type a message",
                            isDense: true,
                            suffixIcon: IconButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                    backgroundColor: Colors.transparent,
                                      context: context,
                                      builder: (builder) => bottomSheet());
                                },
                                icon: const Icon(Icons.attach_file)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            counterText: ''),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: CircleAvatar(
                      child: IconButton(
                        onPressed: () {

                        },
                        icon: const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget bottomSheet() {
    return SizedBox(
      height: 120,
      width: MediaQuery.of(context).size.width,
      child: const Card(
        margin: EdgeInsets.only(top: 0, bottom: 30, left: 80, right: 80),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                  children: [
                    CircleAvatar(
                      child: Icon(Icons.insert_drive_file),
                    ),
                    SizedBox(height: 5),
                    Text('File', style: TextStyle(fontSize: 14),)
                  ],
              ),
              SizedBox(width: 40),
              Column(
                children: [
                  CircleAvatar(
                    child: Icon(Icons.image),
                  ),
                  SizedBox(height: 5),
                  Text('Image', style: TextStyle(fontSize: 14),)
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
