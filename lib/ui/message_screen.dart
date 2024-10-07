import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:signwalla/common/colors.dart';
import 'package:signwalla/common/constants.dart';
import 'package:signwalla/models/user_model.dart';
import '../widgets/loading_widget.dart';

class MessageScreen extends StatefulWidget {
  final User currentUser;
  final UserModel selectedUser;

  const MessageScreen({
    super.key,
    required this.currentUser,
    required this.selectedUser,
  });

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String chatId;

  @override
  void initState() {
    super.initState();
    if (widget.currentUser.uid.compareTo(widget.selectedUser.uuid) > 0) {
      chatId = '${widget.selectedUser.uuid}_${widget.currentUser.uid}';
    } else {
      chatId = '${widget.currentUser.uid}_${widget.selectedUser.uuid}';
    }
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      final message = {
        'senderId': widget.currentUser.uid,
        'receiverId': widget.selectedUser.uuid,
        'message': _messageController.text,
        'timestamp': FieldValue.serverTimestamp(),
        'clearedBy': [], // Initialize clearedBy as an empty list
      };

      await _firestore
          .collection(Constants.DB_CHAT_MESSAGE)
          .doc(chatId)
          .collection(Constants.DB_CHAT_MESSAGE)
          .add(message);
      _messageController.clear();
    }
  }

  Stream<QuerySnapshot> getMessages() {
    return _firestore
        .collection(Constants.DB_CHAT_MESSAGE)
        .doc(chatId)
        .collection(Constants.DB_CHAT_MESSAGE)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) {
      return '';
    }
    final DateTime dateTime = timestamp.toDate();
    final DateFormat timeFormat = DateFormat('HH:mm');
    return timeFormat.format(dateTime);
  }

  void _deleteMessage(String messageId) async {
    await _firestore
        .collection(Constants.DB_CHAT_MESSAGE)
        .doc(chatId)
        .collection(Constants.DB_CHAT_MESSAGE)
        .doc(messageId)
        .delete();
  }

  void _clearChat() async {
    final userMessages = await _firestore
        .collection(Constants.DB_CHAT_MESSAGE)
        .doc(chatId)
        .collection(Constants.DB_CHAT_MESSAGE)
        .get();

    for (var doc in userMessages.docs) {
      await doc.reference.update({
        'clearedBy': FieldValue.arrayUnion([widget.currentUser.uid])
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: _firestore
            .collection(Constants.DB_NAME)
            .doc(widget.selectedUser.uuid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Text('User not found');
          }
          var userStatus = snapshot.data!['userStatus'];
          return Scaffold(
            appBar: AppBar(
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(backgroundColor: AppColors.whiteColor),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.selectedUser.firstName,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          userStatus,
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'Clear Chat') {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Clear Chat'),
                            content: const Text(
                                'Are you sure you want to clear your chat messages?'),
                            actions: [
                              TextButton(
                                child: const Text('Cancel'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: const Text('Yes'),
                                onPressed: () {
                                  _clearChat();
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return {'Clear Chat'}.map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      );
                    }).toList();
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: getMessages(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No messages yet'));
                      }

                      final messages = snapshot.data!.docs.where((doc) {
                        final clearedBy = (doc.data()
                                as Map<String, dynamic>?)?['clearedBy'] ??
                            [];
                        return !clearedBy.contains(widget.currentUser.uid);
                      }).toList();

                      return ListView.builder(
                        reverse: true,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final messageData = messages[index];
                          final messageId = messageData.id;
                          var isMe =
                              messageData['senderId'] == widget.currentUser.uid;

                          return GestureDetector(
                            onLongPress: () {
                              if (isMe) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Delete Message'),
                                      content: const Text(
                                          'Are you sure you want to delete this message?'),
                                      actions: [
                                        TextButton(
                                          child: const Text('Cancel'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: const Text('Yes'),
                                          onPressed: () {
                                            _deleteMessage(messageId);
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: isMe
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: isMe
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                    children: [
                                      if (!isMe)
                                        const CircleAvatar(
                                            radius: 14,
                                            backgroundColor:
                                                AppColors.greyColor),
                                      if (!isMe) const SizedBox(width: 8.0),
                                      Flexible(
                                        child: Container(
                                          constraints: BoxConstraints(
                                              maxWidth: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.7),
                                          decoration: BoxDecoration(
                                            color: isMe
                                                ? AppColors.primarymaincolor
                                                : AppColors.greyColor,
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12.0, vertical: 8.0),
                                          child: Column(
                                            crossAxisAlignment: isMe
                                                ? CrossAxisAlignment.end
                                                : CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                messageData['message'],
                                                style: TextStyle(
                                                  color: isMe
                                                      ? Colors.white
                                                      : Colors.black,
                                                ),
                                                softWrap: true,
                                                maxLines: null,
                                                overflow: TextOverflow.visible,
                                              ),
                                              const SizedBox(height: 5.0),
                                              Text(
                                                _formatTimestamp(
                                                    messageData['timestamp']),
                                                style: TextStyle(
                                                  color: isMe
                                                      ? AppColors.greyColor
                                                      : AppColors.whiteColor,
                                                  fontSize: 10.sp,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (isMe) const SizedBox(width: 8.0),
                                      if (isMe)
                                        const CircleAvatar(
                                            radius: 14,
                                            backgroundColor:
                                                AppColors.greyColor),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 10.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.0),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: TextField(
                            controller: _messageController,
                            minLines: 1,
                            maxLines: 3,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            decoration: const InputDecoration(
                              hintText: 'Type a message...',
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 10.0),
                            ),
                          ),
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
        });
  }
}
