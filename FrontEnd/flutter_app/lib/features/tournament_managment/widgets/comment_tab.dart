import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_sight/features/user_managment/controller/user_provider.dart';
class CommentsTab extends StatefulWidget {
  @override
  _CommentsTabState createState() => _CommentsTabState();
}

class _CommentsTabState extends State<CommentsTab> {
  List<CommentMessage> messages = [];

  TextEditingController messageController = TextEditingController();

  //here we should use coloring logic to assign colors to users
  Map<String, Color> userColorMap = {
    'User1': Colors.blue,
    'User2': Colors.green,
    'User3': Colors.red,
    // we may add more as we need
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(
          0, 5, 0, MediaQuery.of(context).size.height * 0.07),
      padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(12)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return messages[index];
                },
              ),
            ),
            _buildInputField(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              decoration: InputDecoration(
                  hintText: 'Type a comment...',
                  hintStyle: Theme.of(context).textTheme.bodyMedium),
            ),
          ),
          Consumer(
            builder: (context, ref, child) {
              final userName = ref.read(userProvider.notifier).getUsername;
              return IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  _sendComment(userName);
                },
              );
            },
          ),
          // (
          //   child: IconButton(
          //     icon: const Icon(Icons.send),
          //     onPressed: () {
          //       _sendComment();
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }

  void _sendComment(String userName) {
    String username = userName; // Replace with the actual username logic
    String commentText = messageController.text;
    if (commentText.isNotEmpty) {
      setState(() {
        messages.add(CommentMessage(
          username: username,
          time: DateTime.now(),
          comment: commentText,
          userColor: userColorMap[username] ?? Colors.red,
        ));
        messageController.clear();
      });
    }
  }
}

class CommentMessage extends StatelessWidget {
  final String username;
  final DateTime time;
  final String comment;
  final Color userColor;

  const CommentMessage({
    super.key,
    required this.username,
    required this.time,
    required this.comment,
    required this.userColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0),
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(
            '${_formatTime()} - ',
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            '$username : ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: userColor,
            ),
          ),
          Expanded(
            child: Text(comment),
          ),
        ],
      ),
    );
  }

  String _formatTime() {
    return '${time.hour}:${time.minute}';
  }
}
