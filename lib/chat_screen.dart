import 'dart:io';

import 'package:chatonline/chat_message.dart';
import 'package:chatonline/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  FirebaseUser _currentUser;
  bool _isLoading = false;

  Future<FirebaseUser> _getUser() async {
    if (_currentUser != null) {
      return _currentUser;
    }
    try {
      final GoogleSignInAccount googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      final AuthResult authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final FirebaseUser user = authResult.user;
      return user;
    } catch (e) {
      return null;
    }
  }

  void _sendMessage({String text, File image}) async {
    final FirebaseUser user = await _getUser();

    if (user == null) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Não foi possível fazer o login. Tente novamente!"),
        backgroundColor: Colors.red,
      ));
    }
    Map<String, dynamic> data = {
      "uid": user.uid,
      "senderName": user.displayName,
      "senderPhotoUrl": user.photoUrl,
      "time": Timestamp.now()
    };

    if (image != null) {
      setState(() {
        _isLoading = true;
      });
      var task = FirebaseStorage.instance
          .ref()
          .child(user.uid + DateTime.now().millisecondsSinceEpoch.toString())
          .putFile(image);
      var taskImage = await task.onComplete;
      var urlImage = await taskImage.ref.getDownloadURL();
      data['urlImage'] = urlImage;
      setState(() {
        _isLoading = false;
      });
    }

    if (text != null) {
      data['text'] = text;
    }
    Firestore.instance.collection("messages").add(data);
  }

  void _signOut() {
    FirebaseAuth.instance.signOut();
    googleSignIn.signOut();
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text("Você saiu com sucesso!"),
    ));
  }

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.onAuthStateChanged.listen((user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_currentUser != null
            ? "Olá, ${_currentUser.displayName}"
            : "Chat Flutter Online"),
        elevation: 0,
        actions: <Widget>[
          _currentUser != null
              ? IconButton(
                  icon: Icon(Icons.exit_to_app),
                  onPressed: _signOut,
                )
              : Container()
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance
                  .collection('messages')
                  .orderBy("time")
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                List<DocumentSnapshot> documents =
                    snapshot.data.documents.reversed.toList();

                return ListView.builder(
                    physics: BouncingScrollPhysics(),
                    itemCount: documents.length,
                    reverse: true,
                    itemBuilder: (context, index) {
                      return ChatMessage(
                        data: documents[index].data,
                        mine: documents[index].data['uid'] == _currentUser?.uid,
                      );
                    });
              },
            ),
          ),
          _isLoading ? LinearProgressIndicator() : Container(),
          TextComposer(
            sendMessage: _sendMessage,
          ),
        ],
      ),
    );
  }
}
