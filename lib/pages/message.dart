import 'package:flutter/material.dart';
import 'package:learnue4app/pages/chat_page.dart';
import 'package:learnue4app/services/auth_services.dart';
import 'package:learnue4app/utils/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

class Message extends StatefulWidget {
  const Message({super.key});

  @override
  State<Message> createState() => _MessageState();
}

class _MessageState extends State<Message> {
  List<dynamic> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  void loadUsers() async {
    final authService = AuthService();
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final fetchedUsers = await authService.getUserData(context);

    final filtered = fetchedUsers
        .where((user) =>
          user['role'] == 'admin' && user['email'] != userProvider.user.email)
        .toList();

    setState(() {
      users = filtered;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isLoggedIn = userProvider.user.accessToken.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: !isLoggedIn
          ? const Center(
              child: Text(
                "You're not logged in",
                style: TextStyle(fontSize: 18),
              ),
            )
          : isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : users.isEmpty
                  ? const Center(
                      child: Text("No users found"),
                    )
                  : ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];

                        return ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: Text(user['name'] ?? 'No Name'),
                          subtitle: Text(user['email'] ?? 'No Email'),
                          onTap: () {
                            Get.to(() => ChatScreen(
                                currentUser: userProvider.user,
                                otherUser: user));
                          },
                        );
                      },
                    ),
    );
  }
}
