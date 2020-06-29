import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool mine;

  const ChatMessage({Key key, this.data, this.mine}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        children: <Widget>[
          !mine
              ? Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(data['senderPhotoUrl']),
                  ),
                )
              : Container(),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: <Widget>[
                data['urlImage'] != null
                    ? Image.network(
                        data['urlImage'],
                        width: 250,
                      )
                    : Text(
                        data['text'],
                        style: TextStyle(fontSize: 16),
                      ),
                Text(
                  data['senderName'],
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                )
              ],
            ),
          ),
          mine
              ? Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(data['senderPhotoUrl']),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
