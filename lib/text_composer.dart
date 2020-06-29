import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {
  final Function({String text, File image}) sendMessage;

  const TextComposer({Key key, this.sendMessage}) : super(key: key);

  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  bool _isComposing = false;
  TextEditingController _controller = TextEditingController();

  void handleSubmit(String message) {
    widget.sendMessage(text: message);
    _controller.clear();
    setState(() {
      _isComposing = false;
    });
  }

  void getImage() {}

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.photo_camera),
            onPressed: () async {
              var image =
                  await ImagePicker.pickImage(source: ImageSource.camera);
              if (image == null) return;
              widget.sendMessage(image: image);
            },
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration:
                  InputDecoration.collapsed(hintText: "Enviar uma mensagem"),
              onChanged: (value) {
                setState(() {
                  _isComposing = value.isNotEmpty;
                });
              },
              onSubmitted: handleSubmit,
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed:
                _isComposing ? () => handleSubmit(_controller.text) : null,
          )
        ],
      ),
    );
  }
}
