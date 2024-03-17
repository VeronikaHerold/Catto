import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ForumScreen extends StatefulWidget {
  const ForumScreen({Key? key}) : super(key: key);

  @override
  _ForumScreenState createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  CollectionReference postsCollection =
  FirebaseFirestore.instance.collection('posts');
  CollectionReference repliesCollection =
  FirebaseFirestore.instance.collection('replies');

  late User? currentUser;
  late ImagePicker _picker;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    _picker = ImagePicker();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forum'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: postsCollection.orderBy('timestamp', descending: true).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Fehler: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          List<DocumentSnapshot> documents = snapshot.data!.docs;

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final post = documents[index].data() as Map<String, dynamic>;
              final bool isOwner = currentUser != null &&
                  currentUser!.uid == post['userUid'];
              return Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    post['title'] ?? 'Kein Titel',
                    style: TextStyle(
                      fontSize: 18, // Ändere die Schriftgröße nach Bedarf
                      fontWeight: FontWeight.bold, // Mache den Text fett
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Von: ${post['user'] != null ? post['user'] : 'Anonym'}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Gepostet am: ${_formatDateTime(post['timestamp'])}',
                      ),
                      SizedBox(height: 8),
                      Text(
                        post['content'] ?? 'Kein Inhalt',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (post['imageUrl'] != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              width: 100, // Ändere die Breite des Bildbereichs nach Bedarf
                              child: Image.network(post['imageUrl']),
                            ),
                          ],
                        ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostDetails(
                          post: documents[index],
                          isOwner: isOwner,
                          onDelete: () {
                            _deletePost(documents[index]);
                          },
                          onEdit: () {
                            _editPost(documents[index]);
                          },
                          onReply: () {
                            _showAddReplyDialog(documents[index]);
                          },
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreatePostDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreatePostDialog() async {
    TextEditingController titleController = TextEditingController();
    TextEditingController contentController = TextEditingController();
    final User? user = FirebaseAuth.instance.currentUser;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Beitrag erstellen'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Titel',
                    ),
                  ),
                  TextField(
                    controller: contentController,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      labelText: 'Inhalt',
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      ImagePicker imagePicker=ImagePicker();
                      XFile? image = await imagePicker.pickImage(source: ImageSource.gallery);
                      print('&{image?.path}');
                      if (image != null) {
                        // Bild in Firebase Storage hochladen
                        String imageUrl = await _uploadImageToStorage(image.path);
                        // Setze die Bild-URL zum Inhalt-Controller
                        contentController.text += '\n\n![Bildbeschreibung]($imageUrl)';
                        setState(() {}); // Dialog neu laden, um das Bild anzuzeigen
                      }
                    },
                    child: Text('Bild hochladen'),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Abbrechen'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Veröffentlichen'),
                  onPressed: () {
                    _addPostToFirebase(
                      titleController.text,
                      contentController.text,
                      user,
                    );
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<String> _uploadImageToStorage(String imagePath) async {
    File imageFile = File(imagePath);
    try {
      Reference ref = FirebaseStorage.instance.ref().child('images').child(DateTime.now().toString());
      await ref.putFile(imageFile);
      String downloadURL = await ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print("Fehler beim Hochladen des Bildes: $e");
      return '';
    }
  }

  void _addPostToFirebase(String title, String content, User? user) {
    postsCollection.add({
      'title': title,
      'content': content,
      'user': user != null
          ? user.displayName ?? user.email ?? 'Unbekannt'
          : 'Anonym',
      'userUid': user != null ? user.uid : '',
      'timestamp': DateTime.now(),
    });
  }

  void _editPost(DocumentSnapshot post) async {
    TextEditingController titleController = TextEditingController(text: post['title']);
    TextEditingController contentController = TextEditingController(text: post['content']);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Beitrag bearbeiten'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Titel',
                ),
              ),
              TextField(
                controller: contentController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  labelText: 'Inhalt',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Abbrechen'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Speichern'),
              onPressed: () {
                _updatePost(post, titleController.text, contentController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _updatePost(DocumentSnapshot post, String title, String content) {
    postsCollection.doc(post.id).update({
      'title': title,
      'content': content,
    });
  }

  void _deletePost(DocumentSnapshot post) {
    postsCollection.doc(post.id).delete();
  }

  void _showAddReplyDialog(DocumentSnapshot post) async {
    TextEditingController replyController = TextEditingController();
    final User? user = FirebaseAuth.instance.currentUser;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Antwort hinzufügen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: replyController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  labelText: 'Deine Antwort',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Abbrechen'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Absenden'),
              onPressed: () {
                _addReplyToPost(replyController.text, user, post);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _addReplyToPost(String replyContent, User? user, DocumentSnapshot post) {
    postsCollection.doc(post.id).collection('replies').add({
      'content': replyContent,
      'user': user != null
          ? user.displayName ?? user.email ?? 'Unbekannt'
          : 'Anonym',
      'timestamp': DateTime.now(),
    });
  }
}

String _formatDateTime(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();
  return '${dateTime.day}.${dateTime.month}.${dateTime.year}';
}

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post['title'] ?? 'Kein Titel'),
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
              'Von: ${widget.post['user'] != null ? widget.post['user'] : 'Anonym'}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Gepostet am: ${_formatDateTime(widget.post['timestamp'])}',
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(widget.post['content'] ?? 'Kein Inhalt'),
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
                      title: Text(reply['content'] ?? 'Kein Inhalt'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Von: ${reply['user'] != null ? reply['user'] : 'Anonym'}',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                          Text(
                            'Gepostet am: ${_formatDateTime(reply['timestamp'])}',
                          ),
                        ],
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
              child: Text('Antwort hinzufügen'),
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
          title: Text('Löschen bestätigen'),
          content: Text('Möchtest du diesen Beitrag wirklich löschen?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Nein, nicht löschen
              },
              child: Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Ja, löschen
              },
              child: Text('Löschen'),
            ),
          ],
        );
      },
    );

    if (result != null && result) {
      widget.onDelete(); // onDelete callback aufrufen, wenn Benutzer Löschung bestätigt
      Navigator.of(context).pop(); // Schließe den PostDetails-Bildschirm
    }
  }

  void _editPost() async {
    widget.onEdit(); // onEdit callback aufrufen
    // PostDetails-Bildschirm neu laden, um Änderungen zu reflektieren
    setState(() {});
  }
}

void main() {
  runApp(MaterialApp(
    home: ForumScreen(),
  ));
}
