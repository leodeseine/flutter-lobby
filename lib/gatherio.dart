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

  Lobby(this.game);


  Future<void> start(){
    assert(this.ref != null);
    return this.update({"started": FieldValue.serverTimestamp()});
  }

Future<void> join({String id}) async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    // assert user is connected
    final lobbies = Firestore.instance
      .collection("games").document(this.game)
      .collection("lobbies");

    if (id == null){
      DocumentReference doc = await lobbies.add({"creator":user.uid,
          "open":false,
          "created": FieldValue.serverTimestamp(),
          "updated":FieldValue.serverTimestamp()});
      id = doc.documentID;
    }
    this.ref = lobbies.document(id);
    DocumentSnapshot tmpSnap =  await this.ref.get();
    assert(tmpSnap.exists);

    return this.ref
    .collection("members").document(user.uid).setData({"joined": FieldValue.serverTimestamp()});
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

  Future<bool> isInLobby(String memberId) async {
    DocumentSnapshot snapshot = await this.ref.collection("members").document(memberId).get();
    return snapshot.exists;
  }

  // todo : message page length
  Future<QuerySnapshot> messages({bool descending=false}){
    return this.ref.collection("messages").orderBy("created",descending: descending).getDocuments();
  }

  Future<void> sendMessage(String message) async {
    assert(message != null && message.isNotEmpty);
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    this.ref.collection("messages").add({
      "created": FieldValue.serverTimestamp()
      , "message": message
      , "sender": user.uid
    });
  }

static Future<QuerySnapshot> list(String game,{bool started=false}) {
  return Firestore.instance.collection("games").document(game)
  .collection("lobbies").where("started",isNull: !started).getDocuments();
}


}