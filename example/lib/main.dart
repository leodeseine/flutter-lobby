import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:gatherio/gatherio.dart';

import 'package:gatherio/gatherio.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  bool connected = false;
  String connectionState = "Unknown";
  String userId = "Unknown";
  FirebaseUser user;
  @override
  void initState(){
    super.initState();
    initPlatformState();
    initFirebaseUser();
  }

  void onClick(){
    setState(() {
      if (this.user == null){
        initFirebaseUser();
      }else{
        disconnectUser();
      }
    });
  }

  Future<void> disconnectUser() async {
    await FirebaseAuth.instance.signOut();
    this.userId = "";
    connectionState = "Connect";
    this.user = null;
  }

  Future<void> initFirebaseUser() async {
    FirebaseUser userfb =  await FirebaseAuth.instance.signInAnonymously();
    this.user = userfb;
    setState(() {
          userId = this.user.uid;
          connectionState = "Disconnect";
        });
  }

  Future<void> createLobby() async {
      Lobby lobby = new Lobby("test");
      await lobby.join();
      await lobby.sendMessage("Lobby crée le " + DateTime.now().toString());
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await Gatherio.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: ListView(
          children: [
            RaisedButton(onPressed: onClick
            ,child: Text(connectionState)),
            Text(userId),
            RaisedButton(onPressed: createLobby,child: Text("Create Lobby"))
          ],
        ),
      ),
    );
  }
}
