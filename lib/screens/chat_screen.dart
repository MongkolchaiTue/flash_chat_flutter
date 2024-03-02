import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  dynamic loggedInUser;
  String email = '';
  String messageText = '';
  int messageItem = 0;

  void getCurrentUser() {
    try {
      if (kAppFbAuth.currentUser != null) {
        loggedInUser = kAppFbAuth.currentUser;
        email = loggedInUser.email;
      } else {
        throw ('FirebaseAuth currentUser is null');
      }
    } catch (e) {
      print(e);
    }
  }

  getMessages() async {
    final messages = await kAppFbStore.collection('messages').get();
    for (var message in messages.docs) {
      print(message.data());
    }
  }

  void messagesStream() async {
    await for (var snapshots
        in await kAppFbStore.collection('messages').snapshots()) {
      for (var message in snapshots.docs) {
        print(message.data());
      }
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsFlutterBinding.ensureInitialized();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                //Implement logout functionality
                // getMessages();
                messagesStream();
                kAppFbAuth.signOut();
                // _firestore.terminate();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat ' '${email}'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            //height: 50.0,
            decoration: kMessageContainerDecoration,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: messageTextController,
                    style: TextStyle(color: Colors.blueAccent),
                    decoration: kMessageTextFieldDecoration,
                    onChanged: (value) {
                      //Do something with the user input.
                      messageText = value;
                    },
                  ),
                ),
                TextButton(
                  child: Text(
                    'Send',
                    style: kSendButtonTextStyle,
                  ),
                  onPressed: () {
                    //Implement send functionality.
                    //messageText + loggedInUser.email
                    messageTextController.clear();
                    kAppFbStore.collection('messages').add({
                      'text': messageText,
                      'sender': email,
                    });
                  },
                ),
              ],
            ),
          ),
          Container(
            decoration: kMessageContainerDecoration,
            child: messageStreamBuilder(),
          ),
        ],
      ),
    );
  }

  StreamBuilder<QuerySnapshot<Object?>> messageStreamBuilder() {
    return StreamBuilder<QuerySnapshot>(
      stream: kAppFbStore.collection('messages').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshots) {
        if (snapshots.hasError) {
          print('Something went wrong');
          return const Text('Something went wrong');
        }

        if (snapshots.connectionState == ConnectionState.waiting) {
          print('Loading');
          // return const Text('Loading');
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }

        // Access the QuerySnapshot
        QuerySnapshot querySnapshot = snapshots.requireData;
        return SizedBox(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            // reverse: true,
            children: querySnapshot.docs.reversed
                .map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;
                  bool isMe = loggedInUser.email == data['sender'] ? true : false;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          data['sender'],
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      MessageBubble(text: data['text'], isMe: isMe),
                      // MessageBubble(text: '${messageItem++} ${data['text']}' , isMe: isMe),
                    ],
                  );
                })
                .toList()
                .cast(),
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({required this.text, required this.isMe});
  final String text;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: isMe ? BorderRadius.only(
          topLeft: Radius.circular(15.0),
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(20)) :
          BorderRadius.only(
          topRight: Radius.circular(15.0),
        bottomRight: Radius.circular(15),
        bottomLeft: Radius.circular(20)),
      elevation: 5.0,
      color: isMe ?  Colors.lightBlueAccent : Colors.purpleAccent,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          '$text',
          textAlign: isMe ? TextAlign.right : TextAlign.left,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }
}
