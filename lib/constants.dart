import 'package:flutter/material.dart';
import 'package:flash_chat/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const String kAppName = DefaultFirebaseOptions.appName;
late final FirebaseApp kAppFb;
late final FirebaseAuth kAppFbAuth;
late final FirebaseFirestore kAppFbStore;
Future<void> iniAppFirebase() async {
    try {
      kAppFb = await Firebase.initializeApp(
        // name: DefaultFirebaseOptions.currentPlatform.projectId,
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print(kAppFb);

      kAppFbAuth = FirebaseAuth.instanceFor(app: kAppFb);
      print(kAppFbAuth);

      kAppFbStore = FirebaseFirestore.instanceFor(app: kAppFb);
      print(kAppFbStore);
    } catch (e) {
      throw(e);
    }
}

const kSendButtonTextStyle = TextStyle(
  color: Colors.lightBlueAccent,
  fontWeight: FontWeight.bold,
  fontSize: 18.0,
);

const kMessageTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  hintText: 'Type your message here...',
  border: InputBorder.none,
);

const kMessageContainerDecoration = BoxDecoration(
  border: Border(
    top: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
  ),
);

const kTextFieldDecoration = InputDecoration(
  hintText: 'Enter your Text',
  hintStyle: TextStyle(color: Colors.black54),
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.lightBlueAccent, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);
