import 'package:flutter_test/flutter_test.dart';

import 'package:gatherio/gatherio.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main(){

  /*test('adds one to input values', () {
    final calculator = new Calculator();
    expect(calculator.addOne(2), 3);
    expect(calculator.addOne(-7), -6);
    expect(calculator.addOne(0), 1);
    expect(() => calculator.addOne(null), throwsNoSuchMethodError);
  });*/

  test('create a lobby',()async{
    //connect player
    final FirebaseUser user = await FirebaseAuth.instance.signInAnonymously();

    //Create lobby
    final lobby = new Lobby("Test");
    expect(lobby.game, "Test");

    // Join lobby
    await lobby.join();
    expect(lobby.ref,isNotNull);
    DocumentSnapshot snapshot = await lobby.ref.get();
    expect(snapshot.exists,isTrue);

    // Member added
    DocumentReference refMember = lobby.ref.collection("members").document(user.uid);
    DocumentSnapshot snapshotMember = await refMember.get();
    expect(snapshotMember.exists,isTrue);
  });
}
