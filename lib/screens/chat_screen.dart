import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  dynamic loggedInUser;
  String email = '';
  String messageText = '';

  void getCurrentUser() {
      try {
        if (kAppFbAuth.currentUser != null) {
          loggedInUser = kAppFbAuth.currentUser;
          email = loggedInUser.email;
        } else {
          throw('FirebaseAuth currentUser is null');
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
    await for ( var snapshots in await kAppFbStore.collection('messages').snapshots()) {
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
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // StreamBuilder<QuerySnapshot>(
            // stream: FirebaseFirestore.instance.collection('messages').snapshots(),
            //   builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            //     if (snapshot.hasError) {
            //       return const Text('Something went wrong');
            //     }
            //
            //     if (snapshot.connectionState == ConnectionState.waiting) {
            //       return const Text("Loading");
            //     }
            //
            //     return ListView(
            //       children: snapshot.data!.docs
            //           .map((DocumentSnapshot document) {
            //         Map<String, dynamic> data =
            //         document.data()! as Map<String, dynamic>;
            //         return ListTile(
            //           title: Text(data['sender']),
            //           subtitle: Text(data['text']),
            //         );
            //       })
            //       .toList()
            //       .cast(),
            //     );
            //   },
            // ),

            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        //Do something with the user input.
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      //Implement send functionality.
                      //messageText + loggedInUser.email

                      kAppFbStore.collection('messages').add({
                        'text': messageText,
                        'sender':email,
                      });

                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
