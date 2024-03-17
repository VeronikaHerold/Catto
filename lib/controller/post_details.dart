import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostDetails extends StatefulWidget {
  final DocumentSnapshot post;
  final bool isOwner;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onReply;

  const PostDetails({
    Key? key,
    required this.post,
    required this.isOwner,
    required this.onDelete,
    required this.onEdit,
    required this.onReply,
  }) : super(key: key);

  @override
  _PostDetailsState createState() => _PostDetailsState();
}

class _PostDetailsState extends State<PostDetails> {
  // Add a GlobalKey to access the state of this widget
  GlobalKey<_PostDetailsState> _key = GlobalKey<_PostDetailsState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post['title'] ?? 'No Title'),
        actions: [
          if (widget.isOwner)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: _editPost,
            ),
          if (widget.isOwner)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'By: ${widget.post['user'] != null ? widget.post['user'] : 'Anonym'}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(widget.post['content'] ?? 'No Content'),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .doc(widget.post.id)
                  .collection('replies')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final replies = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: replies.length,
                  itemBuilder: (context, index) {
                    final reply =
                    replies[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(reply['content'] ?? 'No Content'),
                      subtitle: Text(
                        'By: ${reply['user'] != null ? reply['user'] : 'Anonym'}',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: widget.onReply,
              child: Text('Add Reply'),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete() async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this post?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // No, do not delete
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Yes, delete
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (result != null && result) {
      widget.onDelete(); // Call the onDelete callback if user confirms deletion
      Navigator.of(context).pop(); // Close the PostDetails screen
    }
  }

  void _editPost() async {
    widget.onEdit(); // Call the onEdit callback
    // Reload the PostDetails screen to reflect changes
    _key.currentState?.loadPost();
  }


  // Method to reload the post
  void loadPost() {
    setState(() {});
  }
}
