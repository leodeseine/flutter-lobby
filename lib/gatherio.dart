import 'dart:async';

import 'package:flutter/services.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Gatherio {
  static const MethodChannel _channel =
      const MethodChannel('gatherio');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}


class Lobby {
  String game;
  DocumentReference ref;

  Future<DocumentReference> create({String password="",bool open=false}) async{
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    this.ref = await Firestore.instance
    .collection("games").document(this.game)
    .collection("lobbies")
    .add({"creator":user
    , "password":password
    , "open":open
    , "created":DateTime.now()
    , "updated":DateTime.now()});

    return this.ref;
  }

  Lobby(this.game);


  Future<void> start(){
    assert(this.ref != null);
    return this.update({"started": DateTime.now()});
  }

  Future<void> join({String id}) async {
    if (id == null){
      await this.create();
    }
    FirebaseUser user = await FirebaseAuth.instance.currentUser();

    assert(this.ref != null);
    return this.ref
    .collection("members").document(user.uid).setData({"joined": DateTime.now()});
  }

  Future<void> update(Map<String, dynamic> data){
    assert(this.ref != null);
    return this.ref.updateData(data);
  }

  Future<void> kick(String userId){
    return this.ref.collection("members").document(userId).delete();
  }

  Future<QuerySnapshot> members() {
    return this.ref.collection("members").getDocuments();
  }

  Future<void> updateMember(String memberId,Map<String,dynamic> data) {
    return this.ref.collection("members").document(memberId).updateData(data);
  }

  // todo : message page length
  Future<QuerySnapshot> messages({bool descending=false}){
    return this.ref.collection("messages").orderBy("created",descending: descending).getDocuments();
  }

  Future<void> sendMessage(String message) async {
    assert(message != null && message.isNotEmpty);
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    this.ref.collection("messages").add({
      "created": DateTime.now()
      , "message": message
      , "sender": user
    });
  }

static Future<QuerySnapshot> list(String game,{bool started=false}) {
  return Firestore.instance.collection("games").document(game)
  .collection("lobbies").where("started",isNull: !started).getDocuments();
}


}