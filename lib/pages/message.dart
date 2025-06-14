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

    List<dynamic> updatedUsers = [];

    for (var user in fetchedUsers) {
      if (user['email'] == userProvider.user.email) continue;

      if (userProvider.user.role == 'admin' || user['role'] == 'admin') {
        // Call hasUnread API
        final hasUnread = await authService.hasUnread(
          receiverId: userProvider.user.id.toString(),
          senderId: user['_id'],
        );

        user['hasUnread'] = hasUnread;
        updatedUsers.add(user);
      }
    }

    setState(() {
      users = updatedUsers;
      isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isLoggedIn = userProvider.user.accessToken.isNotEmpty;
    final isAdmin = userProvider.user.role == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        centerTitle: true,
      ),
      body: !isLoggedIn
          ? const Center(
        child: Text(
          "You're not logged in",
          style: TextStyle(fontSize: 18),
        ),
      )
          : isLoading
          ? const Center(child: CircularProgressIndicator())
          : users.isEmpty
          ? const Center(child: Text("No users found"))
          : isAdmin
          ? _buildAdminListView(userProvider.user)
          : _buildUserListView(userProvider.user),
    );
  }

  Widget _buildAdminListView(dynamic currentUser) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return ListTile(
          leading: Stack(
            children: [
              const CircleAvatar(radius: 25,child: Icon(Icons.person)),
              if (user['hasUnread'] == true)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.priority_high,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          title: Text(user['name'] ?? 'No Name'),
          subtitle: Text(user['email'] ?? 'No Email'),
          trailing: const Icon(Icons.message, color: Colors.blue),
          onTap: () {
            Get.to(() => ChatScreen(
              currentUser: currentUser,
              otherUser: user,
            ));
          },
        );
      },
    );
  }

  Widget _buildUserListView(dynamic currentUser) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final isOnline = user['isOnline'] ?? true;
        final hasUnread = user['hasUnread'] == true;

        return Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.black,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black87,
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 120,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          color: Colors.white24,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 20,
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.blueGrey,
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: user['profileImage'] != null
                                  ? Image.network(
                                user['profileImage'],
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.grey[400],
                                ),
                              )
                                  : Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.grey[400],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 6,
                            right: 6,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: isOnline ? Colors.green : Colors.grey,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                          if (hasUnread)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.mail,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        user['name'] ?? 'No Name',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user['email'] ?? 'No Email',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getRoleColor(user['role']),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _getRoleColor(user['role']),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          user['role']?.toUpperCase() ?? 'USER',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.message,
                            size: 18, color: Colors.white),
                        label: const Text(
                          'Send Message',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[400],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        onPressed: () {
                          Get.to(() => ChatScreen(
                            currentUser: currentUser,
                            otherUser: user,
                          ));
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getRoleColor(String? role) {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'teacher':
        return Colors.green;
      case 'student':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}
